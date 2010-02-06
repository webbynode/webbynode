require 'yaml'

module Webbynode
  class DirectoryNotFound < StandardError; end
  
  class Io
    class KeyAlreadyExists < StandardError; end
    
    TemplatesPath = File.join(File.dirname(__FILE__), '..', 'templates')
    
    def app_name
      Dir.pwd.split("/").last.gsub(/[\.| ]/, "_")
    end
    
    def exec(s, redirect_stderr=true)
      `#{s}#{redirect_stderr ? " 2>&1" : ""}`
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
    
    def log(text, notify=false)
      notify = :simple unless notify

      case notify
      when :simple
        notify = false
        puts "#{text}"
        
      when :notify
        notify = true
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
        puts "            WARNING: #{text}"
      
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
    
    def create_local_key(passphrase="")
      unless File.exists?(Webbynode::Commands::AddKey::LocalSshKey)
        exec "ssh-keygen -t rsa -N \"#{passphrase}\" -f #{Webbynode::Commands::AddKey::LocalSshKey}"
      end
    end
    
    def create_file(file_name, contents, executable=nil)
      File.open(file_name, "w") do |file|
        file.write(contents)
      end
      FileUtils.chmod 0755, file_name if executable
    end
    
    def delete_file(file_name)
      File.delete(file_name)
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
    
    def properties(s)
      (@properties||={})[s] = Properties.new(s)
    end
    
    def general_settings
      @general_settings ||= properties("#{ENV['HOME']}/.webbynode")
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