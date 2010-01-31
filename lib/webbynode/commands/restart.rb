module Webbynode::Commands
  class Restart < Webbynode::Command
    
    add_alias "reboot"
    
    requires_initialization!
        
    def execute
      api.webbies.each do |webby|    
        if webby[1][:ip].eql?(git.parse_remote_ip)
          if webby[1][:status].eql?("Active")
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