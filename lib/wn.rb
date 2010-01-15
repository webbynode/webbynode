$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pp'

module Wn
  VERSION = '0.0.1'
  
  class App
    attr_accessor :command
    attr_accessor :params
    
    def initialize(command)
      parse command
    end
    
    def run
      send command
    end
    
    def parse(parts)
      @command = parts.shift
      @params = parts
    end
    
    def push
      unless dir_exists(".git")
        out "Not an application or missing initialization. Use 'webbynode init'."
        return
      end
      
      out "Publishing #{app_name} to Webbynode..."
      sys_exec "git push webbynode master"
    end
    
    def init
      if params.size < 1
        out "usage: webbynode init webby_ip [host]" 
        return
      end
      
      webby_ip, host = *params
      host = app_name unless host
      
      unless file_exists(".pushand")
        out "Initializing deployment descriptor for #{host}..."
        create_file ".pushand", "#! /bin/bash\nphd $0 #{host}\n"
        sys_exec "chmod +x .pushand"
      end
      
      unless file_exists(".gitignore")
        out "Creating .gitignore file..."
        create_file ".gitignore", <<EOS
config/database.yml
log/*
tmp/*
db/*.sqlite3
EOS
      end

      if dir_exists(".git")
        out "Adding Webbynode remote host to git..."
      else
        out "Initializing git repository..."
      end
      
      git_init webby_ip
    end
    
    def git_init(ip)
      sys_exec "git init" unless dir_exists(".git")
      
      sys_exec "git remote add webbynode git@#{ip}:#{app_name}"
      
      sys_exec "git add ."
      sys_exec "git commit -m \"Initial commit\""
    end
    
    def app_name
      Dir.pwd.split("/").last.gsub(/\./, "_")
    end
    
    def dir_exists(dir)
      File.directory?(dir)
    end
    
    def out(line)
      puts line
    end
    
    def file_exists(file)
      File.exists?(file)
    end
    
    def create_file(filename, contents)
      File.open(filename, "w") do |file|
        file.write(contents)
      end
    end
    
    def sys_exec(cmd)
      raise "Tried to run: #{cmd}" if $testing
      `#{cmd}`
    end
  end
end