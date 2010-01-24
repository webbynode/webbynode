module Webbynode
  class Command
    attr_reader :params, :options
    Aliases = {}
    Settings = {}
    
    def self.inherited(child)
      Settings[child] ||= {}
    end
    
    class << self
      # classes that requires checking
      # for webbynode init must call
      # this method
      def requires_initialization!
        Settings[self][:requires_initialization!] = true
      end
      
      def requires_options!
        Settings[self][:requires_options!] = true
      end
      
      def requires_pushed_application!
        Settings[self][:requires_pushed_application!] = true
      end
      
      def for(command)
        Webbynode::Commands.const_get command_class_name(command)
      rescue NameError
        puts "Command \"#{command}\" doesn't exist"
      end

      def add_alias(alias_name)
        Aliases[alias_name] = self.name.split("::").last
      end

      def command_class_name(command)
        return Aliases[command] if Aliases[command]
        class_name = command.split("_").inject([]) { |arr, item| arr << item.capitalize }.join("")
      end
    end
    
    def initialize(*args)
      @params = []
      @options = {}
      parse_args(args)
    end
    
    def io
      @@io ||= Webbynode::Io.new
    end
    
    def git
      @@git ||= Webbynode::Git.new
    end
    
    def server
      @server ||= Webbynode::Server.new(git.parse_remote_ip)
    end
    
    def remote_executor
      @remote_executor ||= Webbynode::RemoteExecutor.new(git.parse_remote_ip)
    end
    
    def pushand
      @pushand ||= PushAnd.new
    end
    
    def validate_initialization
      raise Webbynode::GitNotRepoError,
        "Could not find a git repository." unless git.present?
      raise Webbynode::GitRemoteDoesNotExistError,
        "Webbynode has not been initialized for this git repository." unless git.remote_webbynode?
      raise Webbynode::PushAndFileNotFound,
        "Could not find .pushand file, has Webbynode been initialized for this repository?" unless pushand.present?
    end
    
    def validate_options
      raise Webbynode::Commands::NoOptionsProvided,
        "No remote options were provided." if params.empty?
    end
    
    def validate_remote_application_availability
      raise Webbynode::ApplicationNotDeployed,
        "Before being able to run remote commands from your Webby, you must first push your application to it." unless server.application_pushed?
    end
    
    def settings
      Settings[self.class]
    end
    
    def run
      validate_initialization                   if settings[:requires_initialization!]
      validate_options                          if settings[:requires_options!]
      validate_remote_application_availability  if settings[:requires_pushed_application!]
      execute
    end
    
    private

    def parse_args(args)
      while (opt = args.shift)
        if opt =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
          name  = $1
          value = $3 ? $3.gsub(/"/, "") : true
          @options[name.to_sym] = value
        else
          @params << opt
        end
      end
    end
  end
end