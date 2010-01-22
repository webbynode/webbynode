module Webbynode::Commands
  class AddKey < Webbynode::Command
    requires_initialization!

    LocalSshKey = "#{ENV['HOME']}/.ssh/id_rsa.pub"
    
    add_alias "addkey"
    
    def execute
      server.add_ssh_key LocalSshKey, options[:passphrase]

    rescue Webbynode::InvalidAuthentication
      puts "Could not connect to server: invalid authentication."

    rescue Webbynode::PermissionError
      puts "Could not create an SSH key: permission error."
    end
  end
end