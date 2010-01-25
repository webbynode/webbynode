module Webbynode::Commands
  class Help < Webbynode::Command
    
    include Webbynode::Helpers
    
    def execute
      log_and_exit read_template('help')
    end
  end
end