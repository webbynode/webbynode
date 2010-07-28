module Webbynode::Commands
  class Addons < Webbynode::Command
    SUPPORTED_ADDONS = ["mongodb", "redis", "memcached", "beanstalkd"]

    summary "Manages you application's add-ons"
    parameter :action, "add, remove or show", 
      :required => false, :validate => { :in => ['add', 'remove', 'show']}
    parameter :addon, "name of the addon", 
      :required => false, :validate => { :in => SUPPORTED_ADDONS }

    add_alias "addon"
    
    def execute
      show_summary and return unless action = param(:action)
      send(action)
    end
    
    private
    
    def add
      return unless validate_addon('add')
      
      if @addons.include?(@addon)
        io.log("Add-on '#{@addon}' was already included")
      else
        @addons << @addon
        io.add_multi_setting 'addons', @addons
        io.log("Add-on '#{@addon}' added")
      end
    end
    
    def remove
      return unless validate_addon('remove')
      
      if @addons.include?(@addon)
        @addons.delete(@addon)
        io.add_multi_setting 'addons', @addons
        io.log("Add-on '#{@addon}' removed")
      else
        io.log("Add-on '#{@addon}' not installed")
      end
    end
    
    def validate_addon(verb)
      unless @addon = param(:addon)
        io.log("Missing addon to #{verb}. Type 'wn addons' for a list of available addons.")
        return false
      end
      
      unless SUPPORTED_ADDONS.include?(@addon)
        io.log("Addon #{@addon} doesn't exist. Type 'wn addons' for a list of available addons.")
        return false
      end
      
      @addons = io.load_setting('addons') || []
      @addons = [] unless @addons.is_a?(Array)
      @addons
    end
    
    def show_summary
      io.log('Available add-ons:')
      io.log("")
      io.log('   Key          Name        Description')
      io.log('  ------------ ----------- ------------------------')
      io.log('   beanstalkd   Beanstalk   Simple, fast workqueue service')
      io.log('   memcached    Memcached   Distributed memory object caching system')
      io.log('   mongodb      MongoDB     Document based database engine')
      io.log('   redis        Redis       Advanced key-value store')
      io.log("")
      
      addons = io.load_setting("addons")
      if addons && addons.is_a?(Array) && addons.any?
        io.log('Currently selected add-ons:')
        io.log('')
        io.log("   #{addons.join(', ')}")
      else        
        io.log("No add-ons currently selected. Use 'wn addons add <name>' to add.")
      end
      io.log('')
      
      true
    end
  end
end