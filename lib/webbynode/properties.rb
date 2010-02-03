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
          self[$1.strip.to_s] = $2.strip if line = ~ /([^=]*)=(.*)\/\/(.*)/ || line =~ /([^=]*)=(.*)/
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
      self.each { |key, value| file.puts "#{key}=#{value}\n" }
      file.close
    end
  end
end