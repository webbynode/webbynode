module Webbynode::Engines
  def self.detect
    Detectable.each do |engine_class|
      engine = engine_class.new
      return engine_class if engine.detected?
    end
    return nil
  end

  module Engine
    def self.included(base)
      base.send(:attr_accessor, :engine_name)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def set_name(name)
        @engine_name = name
      end
      
      def git_excludes(*entries)
        @@git_excluded = entries
      end
      
      def git_excluded
        @@git_excluded
      end
      
      def engine_name
        @engine_name || self.name.split('::').last
      end
      
      def engine_id
        self.name.split('::').last.downcase 
      end
    end
    
    module InstanceMethods
      def prepare
        self.class.git_excluded.each do |exc|
          git.remove(exc) if git.tracks?(exc)
          git.add_to_git_ignore exc
        end
      end
      
      def io
        @io ||= Webbynode::Io.new
      end
      
      def valid?
        true
      end
    end
  end
end