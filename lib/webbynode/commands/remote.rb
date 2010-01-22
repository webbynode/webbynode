module Webbynode
  module Commands
    class NoOptionsProvided < StandardError; end
    
    class Remote < Webbynode::Command
      def run
        raise Webbynode::Commands::NoOptionsProvided,
          "No remote options were provided." if params.empty?
        raise Webbynode::GitNotRepoError,
          "Could not find a git repository." unless git.present?
        raise Webbynode::GitRemoteDoesNotExistError,
          "Webbynode has not been initialized for this git repository." unless git.remote_present?
        raise Webbynode::PushAndFileNotFound,
          "Could not find .pushand file, has Webbynode been initialized for this repository?" unless pushand.present?
        
        # Parses Git Config and returns remote ip
        ip = git.parse_remote_ip
        
        # Parses Pushand File and returns remote application name
        pushand.parse_remote_app_name
        
        # Checks to see if the application exists
        raise Webbynode::ApplicationNotDeployed,
          "Before being able to run commands from your Webby, you must first push it." unless remote_executor.application_exists?
        
        # Initiaizes the remote_executor by providing the parsed IP from the git configuration file
        remote_executor.new(ip)
        
        # Executes the command on the remote server inside the application root folder
        remote_executor.exec(params.join(" "))
      end
    end
  end
end