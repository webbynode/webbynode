module Webbynode
  class InvalidAuthentication < StandardError; end
  class PermissionError < StandardError; end
  class ApplicationNotDeployed < StandardError; end
  
  class Server
    attr_accessor :ip, :user, :port
    
    def initialize(ip, user, port)
      @ssh  = Ssh.new(ip, user, port)
      @ip   = ip
      @user = user
      @port = port
    end
    
    def io
      @io ||= Webbynode::Io.new
    end
   
    def remote_executor
      @remote_executor ||= Webbynode::RemoteExecutor.new(ip, user, port)
    end
    
    def pushand
      @pushand ||= Webbynode::PushAnd.new
    end

    def add_ssh_key(key_file, passphrase="")
      io.create_local_key(passphrase) unless io.file_exists?(key_file)
      remote_executor.create_folder("~/.ssh")
      
      key_contents = io.read_file(key_file)
      remote_executor.exec "grep \"#{key_contents}\" ~/.ssh/authorized_keys || (echo \"#{key_contents}\" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys)"
    end
    
    def application_pushed?
      return false if remote_executor.exec("cd #{pushand.parse_remote_app_name}") =~ /No such file or directory/
      true
    end
  end
end