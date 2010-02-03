module Webbynode::Commands
  class Delete < Webbynode::Command
    summary "Removes the current application from your Webby"
    option :force, "Skips confirmation and forces the deletion of the app"
    
    add_alias "rm"
    add_alias "remove"
    
    def execute
      unless pushand.present?
        io.log("Ahn!? Hello, McFly, anybody home?", true)
        return
      end
      
      app_name = pushand.parse_remote_app_name
      if option(:force) or ask("Do you really want to delete application #{app_name} (y/n)? ").downcase == "y"
        notify("Removing [#{app_name}] from your webby...")
        remote_executor.exec "delete_app #{app_name} --force", true
        notify("The application [#{app_name}] has been removed from your webby.\n\nThe webserver is restarting.")
      else
        puts "Aborted."
      end
    end
  end
end