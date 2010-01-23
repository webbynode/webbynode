module Webbynode  
  class RemoteExecutor
    attr_accessor :ip
    
    def ssh
      @ssh
    end
        
    def initialize(ip)
      @ssh = Ssh.new(ip)
    end
    
    def create_folder(f)
      exec "mkdir -p #{f}"
    end
    
    def exec(s)
      ssh.execute s
    end
  end
end