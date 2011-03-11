module Webbynode
  class AppError < StandardError; end

  class Application
    attr_reader :command, :params, :aliases
    
    def initialize(*args)
      args = ["help", "commands"] unless args.any?
      
      if args.first.include?(":")
        arg = args.shift
        args.unshift arg.split(":")[1]
        args.unshift arg.split(":")[0]
      end
      
      @command = args.shift
      @params = args
    end
    
    def execute
      if command_class = Webbynode::Command.for(command)
        cmd = command_class.new(*params)
        cmd.run
      end
    end
  end
end