module Webbynode::Commands
  class Push < Webbynode::Command
    
    requires_initialization!
    
    def execute
      io.log("Pushing application to your Webby.")
      io.exec("git push webbynode master")
    end
  end
end