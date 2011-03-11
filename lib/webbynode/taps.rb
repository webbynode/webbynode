module Webbynode
  class Taps
    attr_reader :database, :database_password
    attr_reader :io, :remote_executor
    attr_reader :user, :password
    attr_reader :pid

    def initialize(database, database_password, io, remote_executor)
      @database = database
      @database_password = database_password
      @io = io
      @remote_executor = remote_executor
    end
    
    def start
      @user = io.random_password
      @password = io.random_password
      
      result = remote_executor.exec("bash -c 'nohup taps server mysql://#{database}:#{database_password}@localhost/#{database} #{@user} #{@password} > /dev/null 2>&1 &\necho $!'")
      result.strip! if result
      
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

      result = remote_executor.exec "kill -9 #{pid}"
      raise "There was a problem stopping taps" unless result == 0
    end
    
    private
    
    def execute(action, options)
      raise "Taps server was not started" unless user
      
      result = io.execute "taps #{action} mysql://#{options[:user]}:#{options[:password]}@localhost/#{options[:database]} http://#{user}:#{password}@#{options[:remote_ip]}:5000"
      
      raise "There was a problem pulling from your remote databse" unless result == 0
    end
  end
end