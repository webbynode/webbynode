module Webbynode::Commands
  class Alias < Webbynode::Command
    
    requires_initialization!
    
    attr_accessor :action, :alias, :command, :session_aliases
    
    parameter :action,  String, "add, remove or show.", :required => true
    parameter :alias,   String, "The custom alias.",    :required => true
    parameter :command, Array,  "Task to perform.",     :required => false
    
    FilePath = ".webbynode/aliases"
    
    def initialize(*args)
      super
      @session_aliases = Array.new
    end
    
    def execute
      
      ensure_aliases_file_exists
      
      read_aliases_file
      
      parse_parameters
      
      send(action)
      
    end

    
    def read_aliases_file
      @session_aliases = Array.new
      io.read_file(FilePath).each_line do |line|
        if line =~ /\[(.+)\] (.+)/
          @session_aliases << "[#{$1}] #{$2}"
        end
      end
    end
    
    private
    
      def ensure_aliases_file_exists
        unless io.file_exists?(FilePath)
          io.exec("touch #{FilePath}")
        end
      end
      
      def parse_parameters
        @action  = param(:action)
        @alias   = param(:alias)
        @command = param(:command).join(" ")
      end

      def add
        append_alias
        write_aliases
      end
      
      def remove
        remove_alias
        write_aliases
      end
      
      def write_aliases
        io.open_file(FilePath, "w") do |file|
          session_aliases.each do |a|
            file << a + "\n"
          end
        end
      end

      def append_alias
        unless command.blank?
          @session_aliases << "[#{@alias}] #{command}"
        end
      end
      
      def remove_alias
        tmp_aliases = @session_aliases
        @session_aliases = Array.new
        tmp_aliases.each do |a|
          if a =~ /\[(.+)\] .+/
            @session_aliases << a unless $1.eql?(@alias)
          end
        end
      end

  end
end