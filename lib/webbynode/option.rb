module Webbynode
  class Option
    attr_reader :name, :kind, :desc, :options
    
    def initialize(*args)
      raise "Cannot initialize Parameter without a name" unless args.first
      
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
    end
    
    def required?
      @options[:required]
    end
    
    def value
      @options[:value]
    end
    
    def to_s
      "--#{name.to_s}#{value ? "=#{value.to_s}" : ""}"
    end
  end
end