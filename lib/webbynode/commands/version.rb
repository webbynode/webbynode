module Webbynode::Commands
  class Version < Webbynode::Command
    def execute
      io.log("Rapid Deployment Gem v#{Webbynode::VERSION}", true)
    end
  end
end