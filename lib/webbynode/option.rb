module Webbynode
  class Option
    attr_reader :name, :kind, :desc, :options, :errors
    attr_accessor :value
    
    def Option.name_for(s)
      return $1 if s =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
    end
    
    def initialize(*args)
      raise "Cannot initialize Parameter without a name" unless args.first
      
      @errors = []
      @value = nil
      @options = args.pop if args.last.is_a?(Hash)
      @options ||= {}

      @original_options = @options.clone
      @options[:required] = false if @options[:required].nil?
      
      @name = args[0]
      if args[1].is_a?(String)
        @desc = args[1]
      else
        @kind = args[1]
        @desc = args[2]
      end
      
      @kind ||= String
      @value = [] if @kind == Array
    end
    
    def validate!
      raise Webbynode::Command::InvalidCommand, errors.join("\n") unless valid?
    end
    
    def valid?
      return true if !required? and value.nil?
      @errors = []
      if (validations = @options[:validate])
        if validations.is_a?(Hash)
          validations.each_pair do |key, value|
            @errors << send("#{key}_error", value) unless send(key, value)
          end
        else
          @errors << send("#{validations}_error", value) unless send(validations, value)
        end
      end
      @errors.empty?
    end
    
    def integer(value)
      Integer(value) rescue false
    end
    
    def integer_error(value)
      "Invalid value '#{value}' for #{self.class.name.split("::").last.downcase} '#{self.name}'. It should be an integer."
    end
    
    def in(allowed_values)
      allowed_values.include?(self.value)
    end
    
    def in_error(allowed_values)
      opts = allowed_values.map { |v| "'#{v}'"}
      "Invalid value '#{value}' for #{self.class.name.split("::").last.downcase} '#{self.name}'. It should be one of #{opts.to_phrase("or")}."
    end
    
    def parse(s)
      if s =~ /^--(\w+)(=("[^"]+"|[\w\.]+))*/
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
      @options[:required] == true
    end
    
    def take
      @options[:take]
    end
    
    def to_s
      "--#{name.to_s}#{take ? "=#{take.to_s}" : ""}"
    end
  end
end