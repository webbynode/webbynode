module Webbynode::Commands
  class AuthorizeRoot < Webbynode::Command
    requires_initialization!

    summary "Adds your ssh public key to your Webby's root user"
    option :passphrase, "If present, passphrase will be used when creating a new SSH key", :take => :words

    add_alias "authorizeroot"
    add_alias "authroot"
    
    def execute
      server.add_ssh_root_key LocalSshKey, options[:passphrase].value
      io.log "Your local SSH Key has been added to your Webby's root user", :notify

    rescue Webbynode::InvalidAuthentication
      io.log "Could not connect to webby: invalid authentication.", true

    rescue Webbynode::PermissionError
      io.log "Could not create an SSH key: permission error.", true
      
    end
  end
end