require 'bundler'

module Webbynode
  class Gemfile
    def present?
      io.file_exists?("Gemfile")
    end
    
    def dependencies(args={})
      excluded_groups = (args[:without] || []).map { |g| g.to_sym }
      
      dependencies = Bundler.definition.dependencies
      dependencies.reject! do |d| 
        d.groups.any? { |g| excluded_groups.include? g }
      end
      
      dependencies.map &:name
    end
    
    private
    
    def io
      @@io ||= Io.new
    end
  end
end
