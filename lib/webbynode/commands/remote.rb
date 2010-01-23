module Webbynode::Commands
  class NoOptionsProvided < StandardError; end
  
  class Remote < Webbynode::Command
    requires_initialization!
    requires_options!
    requires_pushed_application!
    
    def execute
      # Parses Pushand File and returns remote application name
      remote_app_name = pushand.parse_remote_app_name
      
      # Executes the command on the remote server inside the application root folder
      remote_executor.exec("cd #{remote_app_name} #{params.join(" ")}")
    end
  end
end