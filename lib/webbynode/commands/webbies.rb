module Webbynode::Commands
  class Webbies < Webbynode::Command
    summary "Lists the Webbies you currently own"
    
    def execute
      puts "Fetching list of your Webbies..."
      puts ""
      
      header =  "  "
      header << "Webbies".ljust(16)
      header << "IP".ljust(16)
      header << "Node".ljust(10)
      header << "Plan".ljust(16)
      header << "Status".ljust(15)
      
      puts header
      
      api.webbies.each_pair do |name, webby|
        str = "  "
        str << name.ljust(16)
        str << webby['ip'].ljust(16)
        str << webby['node'].ljust(10)
        str << webby['plan'].ljust(16)
        str << webby['status']
        
        puts str
      end
    end
  end
end