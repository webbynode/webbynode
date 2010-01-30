module Webbynode::Commands
  class NoOptionsProvided < StandardError; end
  
  class Remote < Webbynode::Command
    summary "Executes commands remotely on your Webby where the app is deployed"
    
    requires_initialization!
    requires_options!
  
    parameter :command, Array, "Commands to execute"
  
    def execute
      unless server.application_pushed?
        io.log "Before being able to run remote commands from your Webby, you must first push your application to it."
        exit
      end
      
      # Parses Pushand File and returns remote application name
      remote_app_name = pushand.parse_remote_app_name
      
      # Notify the user
      io.log("Performing the requested remote command..", true)
      
      # Executes the command on the remote server inside the application root folder
      remote_executor.exec("cd #{remote_app_name}; #{param_values.join(" ")}", true)
    end
  end
end