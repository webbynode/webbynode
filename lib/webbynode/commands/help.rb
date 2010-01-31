module Webbynode::Commands
  class Help < Webbynode::Command
    summary "Shows you general help or help for a specific command"
    parameter :command, "Command to get help on"
    
    def execute
      if param(:command) == "commands"
        puts "Commands:"
        dir = File.join(File.expand_path(File.dirname(__FILE__)), "/*.rb")
        Dir[dir].each do |file|
          command = file.split("/").last
          command.gsub!(/\.rb/, "")
          
          puts "    #{command.ljust(20)} #{Webbynode::Command.class_for(command).setting(:summary)}"
        end
        
      else
        puts Help.for(param(:command)).help
      end
    end
  end
end