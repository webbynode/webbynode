module Webbynode::Commands
  class ChangeDns < Webbynode::Command
    requires_initialization!

    summary "Changes the DNS entry for this application"
    parameter :dns_entry, "New DNS entry for this application"
    
    add_alias "dns"
    
    def execute
      raise CommandError, 
        "Cannot change DNS because you have pending changes. Do a git commit or add changes to .gitignore." unless git.clean?
      
      io.log "Changing DNS to #{param(:dns_entry)}...", :quiet_start
      
      git.delete_file ".webbynode/config"
      handle_dns param(:dns_entry)
      
      app_name = io.app_name
      io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name} #{param(:dns_entry)}\n", true)

      git.add ".pushand"
      git.add ".webbynode/settings" if io.file_exists?(".webbynode/settings")
      git.commit "Changed DNS to \"#{param(:dns_entry)}\""

      io.log "Your application will start responding to #{param(:dns_entry)} after next deployment."
    end
  end
end