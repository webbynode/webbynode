module Webbynode::Commands
  class Help < Webbynode::Command
    summary "Guess what? You're on it!"
    parameter :command, "Command to get help on"
    
    def execute
      if param(:command) == "commands"
        puts "usage: #{"webbynode".bright} #{"COMMAND".bright}"
        puts
        puts "Available commands:"
        dir = File.join(File.expand_path(File.dirname(__FILE__)), "/*.rb")
        Dir[dir].each do |file|
          command = file.split("/").last
          command.gsub!(/\.rb/, "")
          
          puts "    #{command.ljust(15).bright} #{Webbynode::Command.class_for(command).setting(:summary)}"
        end
        puts 
        puts "Try '#{"webbynode help".bright} #{"COMMAND".bright}' for more information."
      else
        kls = Help.for(param(:command))
        if kls
          puts kls.help
        end
      end
    end
  end
end