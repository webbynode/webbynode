require 'launchy'

module Webbynode::Commands
  class Guides < Webbynode::Command
    summary "Opens the Rapp Guides in your browser"
   
    def execute
      Launchy.open "http://wbno.de/rapp"
    end
  end
end