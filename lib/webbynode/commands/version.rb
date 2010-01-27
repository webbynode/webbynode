module Webbynode::Commands
  class Version < Webbynode::Command
    def execute
      io.log("Webbynode Rapid Deployment Gem v#{Webbynode::VERSION}")
    end
  end
end