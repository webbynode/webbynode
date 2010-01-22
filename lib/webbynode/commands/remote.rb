module Webbynode
  module Commands
    class NoOptionsProvided < StandardError; end
    
    class Remote
      attr_accessor :options
      
      def initialize(*options)
        @options = options.join('')
      end
      
      def run
        raise Webbynode::Commands::NoOptionsProvided, "No remote options were provided." if @options.empty?
        raise Webbynode::GitNotRepoError, "Could not find a git repository." unless git.present?
        raise Webbynode::GitRemoteDoesNotExistError, "Webbynode has not been initialized for this git repository." unless git.remote_present?
        raise Webbynode::PushAndFileNotFound, "Could not find .pushand file, has Webbynode been initialized for this repository?" unless pushand.present?
        
        # Parses Git Config and returns remote ip
        git.parse_remote_ip
        
        # Parses Pushand File and returns remote application name
        pushand.parse_remote_app_name  
        
        # Executes the command on the remote server inside the application root folder
        remote_executor.exec(@options)
      end
    end
  end
end