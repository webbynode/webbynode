module Webbynode
  class AddKeyCommand
    LocalSshKey = "#{ENV['HOME']}/.ssh/id_rsa.pub"
    
    def initialize(*options)
      @named_params = options.pop if options.last.is_a?(Hash)
      @named_params ||= {}
    end
    
    def run
      server.add_ssh_key LocalSshKey, @named_params[:passphrase]

    rescue Webbynode::InvalidAuthentication
      puts "Could not connect to server: invalid authentication."

    rescue Webbynode::PermissionError
      puts "Could not create an SSH key: permission error."
    end
  end
end