module Webbynode::Commands
  class Apps < Webbynode::Command
    include Webbynode::Updater
    
    summary "Lists all apps installed in your Webby"

    def execute
      check_for_updates
      remote_executor.exec "list_apps", true
    end
  end
end