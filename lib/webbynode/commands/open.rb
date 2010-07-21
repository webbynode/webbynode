require 'launchy'

module Webbynode::Commands
  class Open < Webbynode::Command
    requires_initialization!

    summary "Opens the current application in your browser"
   
    def execute
      mapping = "/var/webbynode/mappings/#{io.app_name}.conf"
      url = remote_executor.exec("test -f #{mapping} && cat #{mapping}", false).strip.chomp
      
      if url && !url.empty?
        url = "http://#{url}"
        Launchy.open url
      else
        io.log "Application not found or not deployed."
      end
    end
  end
end