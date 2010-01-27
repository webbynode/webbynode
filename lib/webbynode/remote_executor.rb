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
      exec "mkdir -p #{folder}"
    end
    
    def exec(cmd, echo=false)
      ssh.execute(cmd, echo)
    end
  end
end