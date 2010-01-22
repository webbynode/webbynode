module Webbynode
  class InvalidAuthentication < StandardError; end
  class PermissionError < StandardError; end
  
  class Server
    def add_ssh_key(key_file, passphrase=nil)
      io.create_local_key(key_file, passphrase) unless io.file_exists?(key_file)
      remote_executor.create_folder("~/.ssh", "700")
      
      key_contents = io.read_file(key_file)
      remote_executor.exec "echo \"#{key_contents}\" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"
    end
  end
end