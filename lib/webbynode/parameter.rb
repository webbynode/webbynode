module Webbynode
  class Parameter < Webbynode::Option
    def initialize(*args)
      super
      @options[:required] = true if @original_options[:required].nil?
    end
    
    def validate!
      if required? and self.value === self.default_value
        raise Webbynode::Command::InvalidCommand, "Missing '#{name}' parameter."
      end
      super
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