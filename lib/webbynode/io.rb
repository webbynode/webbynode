require 'yaml'
require 'fileutils'
require 'rbconfig'

module Webbynode
  class DirectoryNotFound < StandardError; end
  
  class Io
    class KeyAlreadyExists < StandardError; end
    
    TemplatesPath = File.join(File.dirname(__FILE__), '..', 'templates')
    
    def self.is_windows?
      Config::CONFIG["host_os"] =~ /mswin|mingw/
    end
    
    def random_password(len=10)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      return newpass
    end
          
    def list_files(dir)
      Dir.glob(dir)
    end
    
    def is_windows?
      Io.is_windows?
    end
    
    def exists_in_path?(file)
      search_in_path { |f| File.exists?("#{f}/#{file}") }
    end
    
    def exec_in_path?(file)
      search_in_path do |f| 
        if is_windows?
          File.executable?("#{f}/#{file}") || 
          File.executable?("#{f}/#{file}.exe") || 
          File.executable?("#{f}/#{file}.bat") || 
          File.executable?("#{f}/#{file}.cmd")
        else
          File.executable?("#{f}/#{file}")
        end
      end
    end
    
    def search_in_path(&blk)
      return false unless block_given?
      entries = ENV['PATH'].split(is_windows? ? ";" : ":")
      entries.any? &blk
    end
    
    def sed(file, from, to)
      contents = File.read(file).gsub(from, to)
      File.open(file, 'w') { |f| f.write(contents) }
    end
    
    def file_matches(file, regexp)
      File.read(file) =~ regexp
    end
    
    def app_name
      Dir.pwd.split("/").last.gsub(/[\.| ]/, "_")
    end
    
    def db_name
      app_name.gsub(/[-._]/, "")      
    end
    
    def mkdir(path)
      raise "Tried to create real directory: #{path}" if $testing
      # TODO: raise "Tried to create real folder: #{path}" if $testing
      FileUtils.mkdir_p(path)
    end
    
    def exec(s, redirect_stderr=true)
      `#{s}#{redirect_stderr ? " 2>&1" : ""}`
    end
    
    def exec2(s, redirect_stderr=true)
      `#{s}#{redirect_stderr ? " 2>&1" : ""}`
      $?
    end
    
    def exec3(s, redirect_stderr=false)
      result = `#{s}#{redirect_stderr ? " 2>&1" : ""}`
      [$? == 0, result]
    end
    
    def execute(s)
      Kernel.exec s
      $?
    end
    
    def directory?(s)
      File.directory?(s)
    end
    
    def file_exists?(f)
      File.exists?(f)
    end
    
    def read_file(f)
      File.read(f)
    end
    
    def open_file(f, a, &blk)
      File.open(f, a, &blk)
    end
    
    def copy_file(from, to)
      FileUtils.cp(from, to)
    end
    
    def log(text, notify=false)
      notify = :simple unless notify

      case notify
      when :notify
        notify = true
        puts "#{text}" 
      
      when :simple
        notify = false
        puts "#{text}" 
      
      when :start
        notify = true
        puts "[Webbynode] #{text}" 
      
      when :quiet_start
        notify = false
        puts "[Webbynode] #{text}" 
      
      when :action
        notify = false
        puts "            #{text}"
      
      when :warning
        notify = false
        puts "WARNING: #{text}"
      
      when :action
        notify = false
        puts "            #{text}"
      
      when :finish
        notify = true
        puts
        puts "[Webbynode] #{text}"
        
      when :error
        notify = true
        puts
        puts "[Webbynode] ERROR: #{text}"
        
      else
        notify = false
        puts "            #{text}"
        
      end
          
      Webbynode::Notify.message(text) if notify
    end

    def log_and_exit(text, notify=false)
      log(text, notify)
      exit
    end
    
    def self.home_dir
      if is_windows?
        if ENV['USERPROFILE'].nil?
          userdir = "C:/My Documents/"
        else
          userdir = ENV['USERPROFILE']
        end
      else
        userdir = ENV['HOME'] unless ENV['HOME'].nil?
      end
    end
    
    def create_local_key(passphrase="")
      unless File.exists?(LocalSshKey)
        mkdir File.dirname(LocalSshKey)
        key_file = LocalSshKey.gsub(/\.pub$/, "")
        exec "ssh-keygen -t rsa -N \"#{passphrase}\" -f \"#{key_file}\""
      end
    end
    
    def create_file(file_name, contents, executable=nil)
      raise "Tried to create real file: #{file_name}" if $testing and !$testing_io
      File.open(file_name, "w") do |file|
        file.write(contents)
      end
      ::FileUtils.chmod 0755, file_name if executable
    end
    
    def create_if_missing(file_name, contents="", executable=nil)
      create_file(file_name, contents, executable) unless file_exists?(file_name)
    end
    
    def delete_file(file_name)
      File.delete(file_name)
    end
    
    def rename_file(old_name, new_name)
      File.rename(old_name, new_name)
    end
    
    def templates_path
      TemplatesPath
    end
    
    def read_from_template(template)
      read_file File.join(templates_path, template)
    end
    
    def create_from_template(file, template)
      contents = read_from_template(template)
      create_file(file, contents)
    end
    
    def add_line(file, line)
      create_if_missing(file)
      contents = File.read(file)
      return if contents.include?("#{line}")
      File.open(file, 'a') do |f| 
        f.puts "" if !contents.empty? and !(contents =~ /\n$/)
        f.puts line
      end
    end
    
    def properties(s)
      (@properties||={})[s] = Properties.new(s)
    end
    
    def general_settings
      @general_settings ||= properties("#{Io.home_dir}/.webbynode")
    end
    
    def with_settings_for(file, &blk)
      settings = properties(file)
      yield settings
      settings.save
    end
    
    def with_general_settings(&blk)
      yield general_settings
      general_settings.save
    end
    
    def with_setting(&blk)
      mkdir('.webbynode') unless directory?('.webbynode')
      with_settings_for ".webbynode/settings", &blk
    end
    
    def add_general_setting(key, value)
      with_general_settings { |s| s[key] = value }
    end
    
    def remove_setting(key)
      with_setting { |s| s.remove key }
    end
    
    def add_setting(key, value)
      with_setting { |s| s[key] = value }
    end
    
    def add_multi_setting(key, values)
      with_setting { |s| s[key] = "(#{values.join(" ")})" }
    end
    
    def load_setting(key)
      properties(".webbynode/settings")[key]
    end
    
    def config_multi_add(key, new_value)
      raise "Missing Webbynode config file" unless file_exists?(".webbynode/config")
      config = read_yaml(".webbynode/config")
      (config[key] ||= []) << new_value
      write_yaml(config)
    end
    
    def read_yaml(file)
      YAML.load_file(file)
    end
    
    def write_yaml(obj)
      create_file(file, obj.to_yaml)
    end
    
    def read_config(config_file)
      read_file(config_file).split("\n").inject({}) do |hash, line|
        line_parts = line.split("=")
        hash[line_parts.first.strip.to_sym] = line_parts.last.strip
        hash
      end
    end
  end
end