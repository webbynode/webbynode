module Webbynode
  class AppError < StandardError; end

  class Application
    attr_reader :command, :params, :aliases
    
    def initialize(*args)
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