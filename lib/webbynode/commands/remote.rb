module Webbynode
  module Commands
    class NoOptionsProvided < StandardError; end
    
    class Remote
      attr_accessor :options
      
      def initialize(*options)
        @options = options.join('')
      end
      
      def run
        if @options.empty?
          raise Webbynode::Commands::NoOptionsProvided, "No remote options were provided."
        end
        
        git.parse_remote_ip
        
        pushand.parse_remote_app_name
          
        remote_executor.exec(@options)
      end
    end
  end
end