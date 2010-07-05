module Webbynode  
  class RemoteExecutor
    attr_accessor :ip, :port
        
    def initialize(ip, port=nil)
      @ip = ip
      @port = port
    end
    
    def ssh
      @ssh ||= Ssh.new(ip, port)
    end
    
    def create_folder(folder)
      ssh.execute "mkdir -p #{folder}"
    end
    
    def remote_home
      exec('pwd').strip
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