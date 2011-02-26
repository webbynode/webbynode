module Webbynode
  module SshKeys
    # adds a given key string to a remote server,
    # creating the key folder structure if needed
    def add_key_to_remote(key)
      run_remote_command "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; echo \"#{key}\" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"
    end
    
    def add_key_to_remote_user(key, folder)
      run_remote_command "mkdir #{folder}/.ssh 2>/dev/null; chmod 700 #{folder}/.ssh; echo \"#{key}\" >> #{folder}/.ssh/authorized_keys; chmod 644 #{folder}/.ssh/authorized_keys"
    end
    
    # lists all authorized keys on the remote server
    def remote_authorized_keys
      run_remote_command "cat \$HOME/.ssh/authorized_keys"
    end
    
    # checks if a remote server has a given key
    def remote_has_key?(key)
      if keys = remote_authorized_keys
        keys.index(key) 
      end
    end
    
    # name of the local publish ssh key file
    def local_key_file
      "#{ENV['HOME']}/.ssh/id_rsa.pub"
    end
    
    # creates the local key with an optional passphrase
    def create_local_key(passphrase="")
      run "ssh-keygen -t rsa -N \"#{passphrase}\" -f #{local_key_file}"
    end
    
    def local_key(create_when_missing=true)
      create_local_key(named_options["passphrase"]) if create_when_missing and !File.exists?(local_key_file)
      @local_key ||= File.read(local_key_file) 
    end
  end
end