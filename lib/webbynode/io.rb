module Webbynode
  class Io
    class KeyAlreadyExists < StandardError; end
    
    def app_name
      Dir.pwd.split("/").last.gsub(/[\.| ]/, "_")
    end
    
    def exec(s)
      `#{s}`
    end
    
    def directory?(s)
      File.directory?(s)
    end
    
    def read_file(f)
      File.read(f)
    end
    
    def create_local_key(passphrase="")
      unless File.exists?(Webbynode::Commands::AddKey::LocalSshKey)
        exec "ssh-keygen -t rsa -N \"#{passphrase}\" -f #{Webbynode::Commands::AddKey::LocalSshKey}"
      end
    end
  end
end