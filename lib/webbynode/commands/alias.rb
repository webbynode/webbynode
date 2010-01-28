module Webbynode::Commands
  class Alias < Webbynode::Command
    
    requires_initialization!
    
    attr_accessor :action, :command #, :session_file, :session_aliases
    
    parameter :action,  String, "add, remove or show.", :required => true
    parameter :command, Array,  "Task to perform.",     :required => true
    
    File = ".webbynode/aliases"
    
    def execute
      ensure_aliases_file_exists
      
      parse_parameters
      
    end


    
    private
    
      def ensure_aliases_file_exists
        unless io.file_exists?(File)
          io.exec("touch #{File}")
        end
      end
      
      def parse_parameters
        @action   = param(:action)
        @command  = param(:command).join(" ")
      end

  end
end