module Webbynode::Commands
  class Settings < Webbynode::Command
    summary "Manages application settings"
    parameter :action,  String, "add, remove or show", :required => false, :validate => { :in => ["add", "remove", "show"] }
    parameter :setting,  String, "setting to act on", :required => false
    parameter :value,    String, "value, when adding", :required => false
    
    def execute
      action = param(:action) || :show
      send action
    end
    
    private

    def show
      io.with_setting do |hash|
        hash.each_pair do |k, v|
          io.log "#{k.bright} = #{v.to_s.bright}"
        end
      end
    end
    
    def add
      io.add_setting param(:setting), param(:value)
    end
    
    def remove
      io.remove_setting param(:setting)
    end
  end
end