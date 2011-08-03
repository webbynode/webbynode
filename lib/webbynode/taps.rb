require 'taps/operation'
require 'taps/cli'
require 'cgi'

module Webbynode
  class Taps
    attr_reader :database, :database_password
    attr_reader :io, :remote_executor
    attr_reader :user, :password
    attr_reader :pid

    attr_accessor :debug

    def initialize(database, database_password, io, remote_executor)
      @database = database
      @database_password = database_password
      @io = io
      @remote_executor = remote_executor
    end
    
    def ensure_gems!
      check_and_install ['taps', '0.3.23'], 'mysql'
    end
    
    def check_and_install(*gems)
      gems.each do |g| 
        if g.is_a?(Array)
          gemd = *g
        else
          gemd = [g]
        end
        
        remote_executor.install_gem *gemd unless remote_executor.gem_installed?(*gemd)
      end
    end
    
    def start
      @user = io.random_password
      @password = io.random_password
      
      command = "bash -c 'nohup taps server mysql://#{database}:#{database_password}@localhost/#{database} #{@user} #{@password} > /dev/null 2>&1 &\necho $!'"
      
      io.log "Executing: #{command}" if debug
      
      result = remote_executor.exec(command)
      result.strip! if result
      
      io.log "Result: #{result}" if debug
      io.log "" if debug
      
      raise "Could not start taps on remote server" unless result =~ /^[0-9]+$/

      @pid = result
    end
    
    def pull(options)
      execute "pull", options
    end
    
    def push(options)
      execute "push", options
    end
    
    def finish
      raise "Taps server was not started" unless user
      
      command = "kill -9 #{pid}"
      
      io.log "Executing: #{command}" if debug

      result = remote_executor.exec command
      
      io.log "Result: #{result}\n" if debug
    end
    
    private
    
    def execute(action, options)
      raise "Taps server was not started" unless user
      
      local_url = "mysql://#{options[:user]}:#{CGI.escape(options[:password])}@localhost/#{options[:database]}"
      remote_url = "http://#{user}:#{CGI.escape(password)}@#{options[:remote_ip]}:5000"
      
      ::Taps::Cli.new([]).clientxfer(action.to_sym, 
        :database_url => local_url, 
        :remote_url => remote_url)
    end
  end
end

class TapsError < StandardError; end

class Taps::Config
  def self.puts(error)
    @error = error
  end
  
  def self.exit(num)
    raise TapsError, @error
  end
end