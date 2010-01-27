module Webbynode::Commands
  class AddKey < Webbynode::Command
    requires_initialization!
    
    option :passphrase, "If present, passphrase will be used when creating a new SSH key", :take => :words

    LocalSshKey = "#{ENV['HOME']}/.ssh/id_rsa.pub"
    
    add_alias "addkey"
    
    def execute
      server.add_ssh_key LocalSshKey, options[:passphrase].value

    rescue Webbynode::InvalidAuthentication
      puts "Could not connect to server: invalid authentication."

    rescue Webbynode::PermissionError
      puts "Could not create an SSH key: permission error."
    end
  end
end