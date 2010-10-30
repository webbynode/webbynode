module Webbynode::Commands
  class Logs < Webbynode::Command
    summary "Tails a your Rails application logs"
    add_alias "log"
    
    def execute
      unless server.application_pushed?
        io.log "Before being able to run remote commands from your webby, you must first push your application."
        exit
      end

      if io.load_setting('engine') =~ /^rails/
        io.log "Connecting to display your Rails application logs..."
        io.log ""
        
        ssh = remote_executor.ssh
        ssh.logs(pushand.parse_remote_app_name)
      else
        io.log "Logs only works for Rails apps."
      end
    rescue Webbynode::GitRemoteDoesNotExistError
      io.log "Remote 'webbynode' doesn't exist. Did you run 'wn init' for this app?"
    end
  end
end