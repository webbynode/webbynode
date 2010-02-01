module Webbynode::Commands
  class ChangeDns < Webbynode::Command
    requires_initialization!

    summary "Changes the DNS entry for this application"
    parameter :dns_entry, "New DNS entry for this application"
    
    add_alias "dns"
    
    def execute
      handle_dns
      app_name = io.app_name
      io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name} #{param(:dns_entry)}\n", true)
      io.log "Your application will start responding to #{param(:dns_entry)} after next deployment."
    end

    def handle_dns
      api.create_record param(:dns_entry), git.parse_remote_ip
    rescue Webbynode::ApiClient::ApiError
      if $!.message =~ /Data has already been taken/
        io.log "The DNS entry for '#{param(:dns_entry)}' already existed, ignoring."
      else
        io.log "Couldn't create your DNS entry: #{$!.message}"
      end
    end
  end
end