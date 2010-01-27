module Webbynode
  class InvalidAuthentication < StandardError; end
  class PermissionError < StandardError; end
  class ApplicationNotDeployed < StandardError; end
  
  class Server
    attr_accessor :ip
    
    def initialize(ip)
      @ssh  = Ssh.new(ip)
      @ip   = ip
    end
    
    def io
      @io ||= Webbynode::Io.new
    end
   
    def remote_executor
      @remote_executor ||= Webbynode::RemoteExecutor.new(ip)
    end
    
    def pushand
      @pushand ||= Webbynode::PushAnd.new
    end

    def add_ssh_key(key_file, passphrase="")
      io.create_local_key(key_file, passphrase) unless io.file_exists?(key_file)
      remote_executor.create_folder("~/.ssh")
      
      key_contents = io.read_file(key_file)
      remote_executor.exec "echo \"#{key_contents}\" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"
    end
    
    def application_pushed?
      return false if remote_executor.exec("cd #{pushand.parse_remote_app_name}") =~ /No such file or directory/
      true
    end
  end
end