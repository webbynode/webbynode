require 'taps/operation'
require 'taps/cli'

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
      
      local_url = "mysql://#{options[:user]}:#{options[:password]}@localhost/#{options[:database]}"
      remote_url = "http://#{user}:#{password}@#{options[:remote_ip]}:5000"
      
      io.log "Running taps #{action}"
      
      ::Taps::Cli.new([]).clientxfer(action.to_sym, 
        :database_url => local_url, 
        :remote_url => remote_url)
    end
  end
end