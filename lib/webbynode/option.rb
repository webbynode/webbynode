module Webbynode
  class Option
    attr_reader :name, :kind, :desc, :options
    attr_accessor :value
    
    def Option.name(s)
      return $1 if s =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
    end
    
    def initialize(*args)
      raise "Cannot initialize Parameter without a name" unless args.first
      
      @value = nil
      @options = args.pop if args.last.is_a?(Hash)
      @options ||= {}
      @options[:required] = true if @options[:required].nil?
      
      @name = args[0]
      if args[1].is_a?(String)
        @desc = args[1]
      else
        @kind = args[1]
        @desc = args[2]
      end
      
      @kind ||= String
      
      if @kind == Array
        @value = []
      end
    end
    
    def parse(s)
      if s =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
        self.value = $3 ? $3.gsub(/"/, "") : true
      end
    end
    
    def array?
      kind == Array
    end
    
    def reset!
      self.value = default_value
    end
    
    def default_value
      array? ? [] : nil
    end
    
    def required?
      @options[:required]
    end
    
    def take
      @options[:take]
    end
    
    def to_s
      "--#{name.to_s}#{take ? "=#{take.to_s}" : ""}"
    end
  end
end