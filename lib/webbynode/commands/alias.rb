module Webbynode::Commands
  class Alias < Webbynode::Command
  
    attr_accessor :action, :alias, :command, :session_aliases
    
    add_alias "aliases"
    
    requires_initialization!
    
    parameter :action,  String, "add, remove or show.", :required => true
    parameter :alias,   String, "The custom alias.",    :required => false # true if action == add or remove
    parameter :command, Array,  "Task to perform.",     :required => false # true if action == add
    
    FilePath = ".webbynode/aliases"
    
    def initialize(*args)
      super
      @session_aliases = Array.new

      # Ensures that the aliases file exists inside the .webbynode/ folder
      ensure_aliases_file_exists
    end
    
    def execute
      
      # Reads out the aliases from the aliases file and stores them in session_aliases
      read_aliases_file
      
      # Parses the parameters that were provided by the user
      parse_parameters
      
      # Initializes the specified action
      send(action)
      
    end

    # Reads out the aliases file and stores all the aliases inside the session_aliases array
    def read_aliases_file
      @session_aliases = Array.new
      io.read_file(FilePath).each_line do |line|
        if line =~ /\[(.+)\] (.+)/
          @session_aliases << "[#{$1}] #{$2}"
        end
      end
    end
    
    # Determines whether an alias already exists inside the session_aliases array
    def exists?(a)
      session_aliases.each do |session_alias|
        if session_alias =~ /\[(.+)\]/
          return true if $1.eql?(a)
        end
      end
      false
    end

    # Ensures that the aliases file exists
    # If the file does not exist, it will be created
    def ensure_aliases_file_exists
      unless io.file_exists?(FilePath)
        io.exec("touch #{FilePath}")
      end
    end
    
    def extract_command(a)
      session_aliases.each do |session_alias|
        if session_alias =~ /\[(.+)\] (.+)/
          return $2 if a.eql?($1)
        end
      end
      false
    end
    
    private
      
      # Parses the paramters provided by the user
      def parse_parameters
        @action  = param(:action)
        @alias   = param(:alias)
        @command = param(:command).join(" ")
      end
      
      # Adds/Writes a new alias to the aliases file
      def add
        append_alias
        write_aliases
        show_aliases
      end
      
      # Removes an alias from the aliases file
      def remove
        remove_alias
        write_aliases
        show_aliases
      end
      
      # Displays the list of currently inserted aliases
      def show
        show_aliases
      end
      
      # Writes all aliases from the session_aliases array to the file
      # It will completely overwrite the existing file
      def write_aliases
        io.open_file(FilePath, "w") do |file|
          session_aliases.each do |a|
            file << a + "\n"
          end
        end
      end
      
      # Appends an alias to the session_aliases unless..
      # - There is no command provided for the alias
      # - There is already an alias that exists with the same name
      def append_alias
        if !command.blank? and !exists?(@alias)
          @session_aliases << "[#{@alias}] #{command}"
        else
          io.log("You must provide a remote command for the alias.") if command.blank?
          io.log("You already have an alias named [#{@alias}].") if exists?(@alias)
        end
      end
      
      # Removes the specified alias from the session_aliases if it exists
      def remove_alias
        tmp_aliases = @session_aliases
        @session_aliases = Array.new
        tmp_aliases.each do |a|
          if a =~ /\[(.+)\] .+/
            @session_aliases << a unless $1.eql?(@alias)
          end
        end
      end
      
      # Outputs every alias from the session_aliases to the user
      def show_aliases
        if session_aliases.any?
          io.log "These are your current aliases.."
          session_aliases.each do |a|
            io.log a
          end
        else
          io.log "You have not yet set up any aliases."
        end
      end
      
  end
end