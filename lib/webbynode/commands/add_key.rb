module Webbynode::Commands
  class AddKey < Webbynode::Command
    LocalSshKey = "#{ENV['HOME']}/.ssh/id_rsa.pub"
    
    def run(param=[], options={})
      server.add_ssh_key LocalSshKey, options[:passphrase]

    rescue Webbynode::InvalidAuthentication
      puts "Could not connect to server: invalid authentication."

    rescue Webbynode::PermissionError
      puts "Could not create an SSH key: permission error."
    end
  end
end