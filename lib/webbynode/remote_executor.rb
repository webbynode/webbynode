module Webbynode  
  class RemoteExecutor
    attr_accessor :ip, :user, :port
        
    def initialize(ip, user=nil, port=nil)
      @ip = ip
      @user = user
      @port = port
    end
    
    def ssh
      @ssh ||= Ssh.new(ip, user, port)
    end
    
    def create_folder(folder)
      ssh.execute "mkdir -p #{folder}"
    end
    
    def remote_home
      exec('pwd').strip
    end
    
    def retrieve_db_password
      password = exec %q(echo `cat /var/webbynode/templates/rails/database.yml | grep password: | tail -1 | cut -d ":" -f 2`)
      password.strip
    end
    
    def exec(cmd, echo=false, exit_code=false)
      begin
        ssh.execute(cmd, echo, exit_code)
      rescue Errno::ECONNREFUSED
        raise Webbynode::Command::CommandError,
          "Could not connect to #{@ip}. Please check your settings and your network connection and try again."
      end
    end
  end
end