module Webbynode::Commands
  class Restart < Webbynode::Command
    
    add_alias "reboot"
    
    requires_initialization!
        
    def execute
      exit if no?("Are you sure you wish to restart your webby? (y/n)")
      
      api.webbies.each do |webby|    
        if webby[1][:ip].eql?(git.parse_remote_ip)
          if webby[1][:status].eql?("on")
            puts "#{webby[0]} will now be rebooted!"
            api.post("/webby/#{webby[1][:name]}/reboot")
          else
            puts "#{webby[0]} is starting up!"
            api.post("/webby/#{webby[1][:name]}/start")
          end
        end
      end
    end
    
  end
end