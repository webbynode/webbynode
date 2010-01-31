module Webbynode::Commands
  class Start < Webbynode::Command
    summary "Starts your Webby, when it's off"
    add_alias "boot"
    
    requires_initialization!
        
    def execute
      exit if no?("Are you sure you wish to start your webby? (y/n)")
      
      api.webbies.each do |webby|
        if webby[1][:ip].eql?(git.parse_remote_ip)
          unless webby[1][:status].eql?("on")
            puts "#{webby[0]} is starting up!"
            api.post("/webby/#{webby[1][:name]}/start")
          else
            puts "#{webby[0]} is already started up."
          end
        end
      end
    end
  end
end