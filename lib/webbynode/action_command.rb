module Webbynode
  class ActionCommand < Webbynode::Command
    attr_reader :action
    
    def self.allowed_actions(actions)
      self.parameter :action, String, actions.join(", "), 
        :validate => { :in => actions },
        :required => false
    end
    
    def execute
      @action = param(:action) || "default"
      send(action)
    end
    
    private
    
    def default
      raise "No default method for #{self.class.name}"
    end
  end
end
