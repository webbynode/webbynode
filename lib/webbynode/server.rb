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
    
    def ssh
      io.execute "ssh -p #{port} git@#{ip}"
    end
   
    def remote_executor
      @remote_executor ||= Webbynode::RemoteExecutor.new(ip, user, port)
    end
    
    def pushand
      @pushand ||= Webbynode::PushAnd.new
    end

    def add_ssh_key(key_file, passphrase="")
      add_ssh_key_in "~", key_file, passphrase
    end
    
    def add_ssh_root_key(key_file, passphrase="")
      create_ssh_settings "/root", true
      add_ssh_key_in "/root", key_file, passphrase, true
    end
    
    def application_pushed?
      return false if remote_executor.exec("cd #{pushand.parse_remote_app_name}") =~ /No such file or directory/
      true
    end
    
    private
    
    def create_ssh_settings(folder, sudo=false)
      sudo = sudo ? "sudo " : ""
      commands = "#{sudo}bash -c 'test -f #{folder}/.ssh/authorized_keys || (mkdir #{folder}/.ssh 2>/dev/null; chmod 700 #{folder}/.ssh; touch #{folder}/.ssh/authorized_keys; chmod 644 #{folder}/.ssh/authorized_keys)'"
      remote_executor.exec commands
    end
    
    def add_ssh_key_in(folder, key_file, passphrase, sudo=false)
      io.create_local_key(passphrase) unless io.file_exists?(key_file)
      remote_executor.create_folder("#{folder}/.ssh")
      
      sudo = sudo ? "sudo " : ""
      key_contents = io.read_file(key_file)
      commands = "#{sudo}bash -c 'grep \"#{key_contents}\" #{folder}/.ssh/authorized_keys || (echo \"#{key_contents}\" >> #{folder}/.ssh/authorized_keys; chmod 644 #{folder}/.ssh/authorized_keys)'"
      remote_executor.exec commands
    end
  end
end