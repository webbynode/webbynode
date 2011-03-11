module Webbynode::Commands
  class Ssh < Webbynode::Command
    summary "Log into your Webby via SSH"

    requires_initialization!
    
    def execute
      server.ssh
    end
  end
end