module Webbynode::Commands
  class Stop < Webbynode::Command
    
    add_alias "shutdown"
    
    requires_initialization!
        
    def execute
      api.webbies.each do |webby|    
        if webby[1][:ip].eql?(git.parse_remote_ip)
          unless webby[1][:status].eql?("off")
            puts "#{webby[0]} will now shutdown!"
            api.post("/webby/#{webby[1][:name]}/shutdown")
          else
            puts "#{webby[0]} is already shutdown."
          end
        end
      end
    end
  end
end