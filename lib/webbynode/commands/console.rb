module Webbynode::Commands
  class Console < Webbynode::Command
    def execute
      unless server.application_pushed?
        io.log "Before being able to run remote commands from your webby, you must first push your application to it."
        exit
      end

      if io.load_setting('engine') == 'rails3'
        io.log "Connecting to Rails console..."
        io.log ""
        
        ssh = remote_executor.ssh
        ssh.console
      else
        io.log "Console only works for Rails 3 apps."
      end
    end
  end
end