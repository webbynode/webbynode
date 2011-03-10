module Webbynode::Commands
  class Webbies < Webbynode::Command
    summary "Lists the Webbies you currently own"
    add_alias "list"
    
    def execute
      puts "Fetching list of your Webbies..."
      puts ""
      
      header =  "  "
      header << "Webbies".ljust(15).color(:white).bright.underline
      header << " "
      header << "IP".ljust(15).color(:white).bright.underline
      header << " "
      header << "Node".ljust(11).color(:white).bright.underline
      header << " "
      header << "Plan".ljust(15).color(:white).bright.underline
      header << " "
      header << "Status".ljust(14).color(:white).bright.underline
      header << " "
      
      puts header

      webbies = spinner { api.webbies }
      
      webbies.each_pair do |name, webby|
        str = "  "
        str << name.ljust(16).color(:yellow).bright
        str << webby['ip'].ljust(16).color(:cyan).bright
        str << webby['node'].ljust(12).color(:cyan).bright
        str << webby['plan'].ljust(16).color(:cyan).bright
        str << (webby['status'] == 'on' ? "on".color(:cyan).bright : "off")

        puts str
      end
    end
  end
end