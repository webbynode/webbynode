module Webbynode
  class AppError < StandardError; end

  class Application
    attr_reader :command, :command_class, :params
    
    def initialize(*args)
      @command = args.shift
      @params = args
    end
    
    def parse_command
      @command_class = Webbynode::Commands.const_get(command_class_name)
    rescue NameError
      puts "Command \"#{command}\" doesn't exist"
    end
    
    def command_class_name
      command.split("_").inject([]) { |arr, item| arr << item.capitalize }.join("")
    end
    
    def execute
      parse_command
      command_class.new(params).run
    end
  end
end