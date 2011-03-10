module Webbynode::Commands
  class Version < Webbynode::Command
    summary "Displays current version of Webbynode Gem"
    def execute
      io.log "#{"Rapid Deployment Gem".color(:white).bright} v#{Webbynode::VERSION.color(:yellow)}"
    end
  end
end