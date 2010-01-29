module Webbynode::Commands
  class AddKey < Webbynode::Command
    requires_initialization!
    
    option :passphrase, "If present, passphrase will be used when creating a new SSH key", :take => :words

    LocalSshKey = "#{ENV['HOME']}/.ssh/id_rsa.pub"
    
    add_alias "addkey"
    
    def execute
      server.add_ssh_key LocalSshKey, options[:passphrase].value
      notify("Your machine's SSH Key has been added to your Webby!")

    rescue Webbynode::InvalidAuthentication
      io.log "Could not connect to server: invalid authentication.", true

    rescue Webbynode::PermissionError
      io.log "Could not create an SSH key: permission error.", true
    end
  end
end