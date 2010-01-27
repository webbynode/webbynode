module Webbynode::Commands
  class Help < Webbynode::Command
    parameter :command, "Command to get help on"
    
    def execute
      puts Help.for(param(:command)).help
    end
  end
end