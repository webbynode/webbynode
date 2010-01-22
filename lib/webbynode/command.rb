module Webbynode
  class Command
    attr_reader :params, :options
    
    def initialize(*args)
      @params = []
      @options = {}
      parse_args(args)
    end
    
    private

    def parse_args(args)
      while (opt = args.shift)
        if opt =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
          name  = $1
          value = $3 ? $3.gsub(/"/, "") : true
          @options[name.to_sym] = value
        else
          @params << opt
        end
      end
    end
  end
end