module Webbynode::Commands
  class Delete < Webbynode::Command
    summary "Deletes current application on your Webby where it's deployed"
    option :force, "Skips confirmation and forces the deletion of the app"
    
    def execute
      app_name = pushand.parse_remote_app_name
      if option(:force) or ask("Do you really want to delete application #{app_name} (y/n)? ").downcase == "y"
        remote_executor.exec "delete_app #{app_name} --force", true
      else
        puts "Aborted."
      end
    end
  end
end