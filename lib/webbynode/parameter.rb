module Webbynode
  class Parameter < Webbynode::Option
    attr_reader :name, :kind, :desc, :options
    
    def initialize(*args)
      super
      @options[:required] = true if @options[:required].nil?
    end
    
    def required?
      @options[:required]
    end
    
    def to_s
      if required?
        "#{name}"
      else
        "[#{name}]"
      end
    end
  end
end