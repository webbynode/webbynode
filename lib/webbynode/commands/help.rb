module Webbynode::Commands
  class Help < Webbynode::Command
    summary "Guess what? You're on it!"
    parameter :command, "Command to get help on"
    
    def execute
      if param(:command) == "commands"
        puts "usage: webbynode COMMAND"
        puts
        puts "Available commands:"
        dir = File.join(File.expand_path(File.dirname(__FILE__)), "/*.rb")
        Dir[dir].each do |file|
          command = file.split("/").last
          command.gsub!(/\.rb/, "")
          
          puts "    #{command.ljust(10)} #{Webbynode::Command.class_for(command).setting(:summary)}"
        end
        puts 
        puts "Try 'webbynode help COMMAND' for more information."
        
      else
        puts Help.for(param(:command)).help
      end
    end
  end
end