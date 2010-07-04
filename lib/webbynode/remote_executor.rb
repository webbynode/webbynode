module Webbynode  
  class RemoteExecutor
    attr_accessor :ip
        
    def initialize(ip)
      @ip = ip
    end
    
    def ssh
      @ssh ||= Ssh.new(ip)
    end
    
    def create_folder(folder)
      ssh.execute "mkdir -p #{folder}"
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