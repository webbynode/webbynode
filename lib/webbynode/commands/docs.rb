require 'launchy'

module Webbynode::Commands
  class Docs < Webbynode::Command
    summary "Opens Webbynode Documentation in your browser"
    add_alias "guides"
   
    def execute
      Launchy.open "http://wbno.de/rapp"
    end
  end
end