module Webbynode::Commands
  class ChangeDns < Webbynode::Command
    requires_initialization!

    summary "Changes the DNS entry for this application"
    parameter :dns_entry, "New DNS entry for this application"
    
    add_alias "dns"
    
    def execute
      handle_dns param(:dns_entry)
      
      app_name = io.app_name
      io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name} #{param(:dns_entry)}\n", true)
      io.log "Your application will start responding to #{param(:dns_entry)} after next deployment."
    end
  end
end