require 'yaml'

module Wn
  module Io
    def create_yaml_file(file, contents, for_real=true)
      raise "Attempted to create #{file}" if $testing and for_real
      File.open(file, "w") do |file|
        file.write contents.to_yaml
      end
    end
    
    def read_yaml_file(file)
      if File.exists?(file)
        YAML.load(File.read(file))
      else
        yield if block_given?
      end
    end
  end
end