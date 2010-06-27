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
      ssh.execute(cmd, echo, exit_code)
    end
  end
end