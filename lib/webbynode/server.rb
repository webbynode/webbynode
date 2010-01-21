module Webbynode
  class InvalidAuthentication < StandardError; end
  class PermissionError < StandardError; end
  
  class Server
    def io
    end
    
    def add_key(key_file, passphrase=nil)
      io.file_exists?(key_file)
      io.create_local_key(key_file, passphrase)
    end
  end
end