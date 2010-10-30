module Webbynode::Commands
  class Console < Webbynode::Command
    summary "Opens a Rails 3 console session"
    
    def execute
      unless server.application_pushed?
        io.log "Before being able to run remote commands from your webby, you must first push your application."
        exit
      end

      if io.load_setting('engine') == 'rails3'
        io.log "Connecting to Rails console..."
        io.log ""
        
        ssh = remote_executor.ssh
        ssh.console(pushand.parse_remote_app_name)
      else
        io.log "Console only works for Rails 3 apps."
      end
    rescue Webbynode::GitRemoteDoesNotExistError
      io.log "Remote 'webbynode' doesn't exist. Did you run 'wn init' for this app?"
    end
  end
end