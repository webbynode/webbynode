module Webbynode
  class Properties < Hash
    attr_accessor :file, :properties
    
    def io
      @io ||= Webbynode::Io.new
    end

    def initialize(file, create=true)
      raise "Tried to instantiate a real property file" if $testing
      @file = file

      begin
        IO.foreach(file) do |line|
          if line = ~ /([^=]*)=(.*)\/\/(.*)/ || line =~ /([^=]*)=(.*)/
            key = $1.strip.to_s
            value = $2.strip 
            
            if value =~ /^\((.*)\)$/
              value = $1.split(' ')
            end
            
            self[key] = value
          end
        end
      rescue
      end
    end
    
    def to_s
      output = "File name #{@file}\n"
      self.each { |key, value| output += " #{key} = #{value}\n" }
      output
    end

    def add(key, value = nil)
      return unless key.length > 0
      self[key] = value
    end

    def remove(key)
      return unless key.length > 0
      self.delete(key)
    end

    def save
      file = File.new(@file, "w+")
      self.converted.each { |key, value| file.puts "#{key}=#{value}\n" }
      file.close
    end
    
    def converted
      hash = self.clone
      hash.each do |k, v|
        if v.is_a?(Array)
          hash[k] = "(#{v.join(" ")})"
        end
      end
      hash
    end
  end
end