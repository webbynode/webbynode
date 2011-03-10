module Webbynode::Commands
  class NoOptionsProvided < StandardError; end
  
  class Remote < Webbynode::Command
    summary "Execute commands on your Webby for the current application"
    
    requires_initialization!
    requires_options!
  
    parameter :command, Array, "Commands to execute"
  
    def execute
      unless server.application_pushed?
        io.log "Before being able to run remote commands from your webby, you must first push your application to it."
        exit
      end
      
      # Parses Pushand File and returns remote application name
      remote_app_name = pushand.parse_remote_app_name
      
      # Notify the user
      io.log "Executing remote command...".color(:cyan)
      
      # Executes the command on the remote server inside the application root folder
      result = spinner {
        remote_executor.exec("cd #{remote_app_name}; #{param_values.join(" ")}", false)
      }

      puts result
    end
  end
end