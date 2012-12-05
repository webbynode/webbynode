begin
  require 'jcode'
rescue LoadError
end

module Webbynode
  class Command
    Aliases = {}
    Settings = {}
    
    InvalidOption = Class.new(StandardError)
    InvalidCommand = Class.new(StandardError)
    CommandError = Class.new(StandardError)
    
    def Command.inherited(child)
      Settings[child] ||= { 
        :parameters_hash => {}, 
        :options_hash    => {}, 
        :parameters      => [], 
        :options         => [] 
      }
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
      
      def description(s)
        Settings[self][:description] = s
      end
      
      def summary(s)
        Settings[self][:summary] = s
      end
      
      def setting(s)
        Settings[self][s]
      end
      
      def parameter(*args)
        param = Parameter.new(*args)
        Settings[self][:parameters] << param
        Settings[self][:parameters_hash][param.name] = param
      end
      
      def option(*args)
        option = Option.new(*args)
        Settings[self][:options] << option
        Settings[self][:options_hash][option.name] = option
      end
      
      def class_for(command)
        Webbynode::Commands.const_get command_class_name(command)
      end
      
      def for(command)
        begin
          class_for(command)
        rescue NameError
          
          # Assumes Command Not Found
          # Will attempt to find/read possible aliases that might
          # have been set up by the user
          if File.directory?('.webbynode')
            a = Webbynode::Commands::Alias.new 
            a.read_aliases_file
            if a.exists?(command)
              remote_command = a.extract_command(command)
              r = Webbynode::Commands::Remote.new(remote_command)
              r.execute
              return
            end
          end  
          
          # If no aliases:
          puts "Command \"#{command}\" doesn't exist"
        end
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
      parse_args(args)
    rescue InvalidCommand, CommandError
      @parse_error = $!.message
    end

    def self.command
      str = ""
      self.name.split("::").last.each_char do |ch| 
        str << "_" if ch.match(/[A-Z]/) and !str.empty?
        str << ch.downcase
      end
      str
    end
    
    def param(p)
      params_hash[p].value if params_hash[p]
    end
    
    def option(p)
      raise CommandError, "Unknown option: #{p}." unless options[p]
      options[p].value if options[p]
    end
    
    def params_hash
      settings[:parameters_hash]
    end
    
    def options
      settings[:options_hash]
    end
    
    def params
      settings[:parameters]
    end

    def param_values
      settings[:parameters].map { |p| p.value }
    end
    
    def self.summary_help
      Settings[self][:summary]
    end
    
    def self.usage
      help = "Usage: webbynode #{command}"
      if (params = Settings[self][:parameters])
        params.each do |p|
          help << " #{p.to_s}"
        end
      end
      
      help << " [options]" if (Settings[self][:options] || []).any?
      help
    end
    
    def self.params_help
      help = []
      if (params = Settings[self][:parameters])
        help << "Parameters:"
        params.each do |p|
          help << "    #{p.name.to_s.ljust(20)}#{p.desc}#{p.required? ? "" : ", optional"}"
        end
      end
      help.join("\n")
    end
    
    def self.options_help
      help = []
      if (options = Settings[self][:options] || []).any?
        help << "Options:"
        options.each do |p|
          help << "    #{p.to_s.ljust(20)}#{p.desc}#{p.required? ? "" : ", optional"}"
        end
      end
      help.join("\n")
    end
    
    def self.help
      help = []
      help << summary_help if summary_help
      help << usage
      help << params_help if Settings[self][:parameters].any?
      help << options_help if (Settings[self][:options] || []).any?
      
      help.join("\n")
    end
    
    def gemfile
      @@gemfile ||= Webbynode::Gemfile.new
    end
    
    def io
      @@io ||= Webbynode::Io.new
    end
    
    def git
      @@git ||= Webbynode::Git.new
    end
    
    def server
      @server ||= Webbynode::Server.new(git.parse_remote_ip, git.remote_user, git.remote_port)
    end
    
    def remote_executor
      git.parse_remote_ip
      @remote_executor ||= Webbynode::RemoteExecutor.new(git.remote_ip, git.remote_user, git.remote_port)
    end
    
    def pushand
      @pushand ||= PushAnd.new
    end
    
    def api
      @@api ||= ApiClient.instance
    end
    
    def notify(msg)
      Webbynode::Notify.message(msg)
    end

    def yes?(question)
      answer = ask(question).downcase
      return true   if %w[y yes].include?(answer)
      return false  if %w[n no].include?(answer)
      exit
    end
    
    def no?(question)
      answer = ask(question).downcase
      return true   if %w[n no].include?(answer)
      return false  if %w[y yes].include?(answer)
      exit
    end
    
    def validate_initialization
      raise CommandError,
        "Ahn!? Hello, McFly, anybody home?" unless git.present?
      raise CommandError,
        "Webbynode has not been initialized for this git repository." unless git.remote_webbynode?
      raise CommandError,
        "Could not find .webbynode folder, has Webbynode been initialized for this repository?" unless io.directory?('.webbynode')
      raise CommandError,
        "Could not find .pushand file, has Webbynode been initialized for this repository?" unless pushand.present?
    end
    
    def validate_options
      raise Webbynode::Commands::NoOptionsProvided,
        "No remote options were provided." if params.empty?
    end
    
    def settings
      Settings[self.class] || {}
    end
    
    def run
      if @parse_error
        puts "#{@parse_error} Use \"webbynode help #{self.class.command}\" for more information."
        puts self.class.usage
        return
      end
      
      if @help
        puts self.class.help
        return
      end
      
      begin
        @@api = ApiClient.instance
        validate_initialization if settings[:requires_initialization!]
        validate_options        if settings[:requires_options!]
        execute
      rescue Webbynode::ApiClient::Unauthorized
        puts "Your credentials didn't match any Webbynode account."
        puts "For more information: http://wbno.de/credts."
      rescue CommandError
        # io.log $!
        puts $!
      end
    end
    
    private
    
    def spinner(&code)
      chars = %w{ | / - \\ }

      result = nil
      t = Thread.new { 
        result = code.call
      }
      while t.alive?
        print chars[0]
        STDOUT.flush

        sleep 0.1

        print "\b"
        STDOUT.flush

        chars.push chars.shift
      end

      print " \b"
      STDOUT.flush

      t.join
      result
    end

    def parse_args(args)
      settings[:options].each { |o| o.reset! }
      settings[:parameters].each { |p| p.reset! }

      i = 0
      while (opt = args.shift)
        if opt == "--help"
          @help = true
          return
        elsif (name = Option.name_for(opt))
          option = settings[:options_hash][name.to_sym]
          raise Webbynode::Command::CommandError, "Unknown option: #{name.to_sym}." unless option
          option.parse(opt)
        else
          raise InvalidCommand, "command '#{self.class.command}' takes no parameters" if settings[:parameters].empty?
          
          if settings[:parameters][i].array?
            settings[:parameters][i].value << opt
          else
            settings[:parameters][i].value = opt
            i += 1
          end
        end
      end
      
      # If help is invoked without any arguments, the first argument will
      # be set to "commands" so it will always display a list of available commands.
      if self.class.command.eql?("help") and param(:command).blank?
        settings[:parameters][0].value = "commands"
      end

      settings[:parameters].each { |p| p.validate! }
      settings[:options].each { |p| p.validate! }
    end
    
    def handle_dns(dns)
      url = Domainatrix.parse("http://#{dns}")
      ip = git.parse_remote_ip
      
      if url.subdomain.empty?
        dns = "#{url.domain}.#{url.public_suffix}"
        io.log "Creating DNS entries for www.#{dns} and #{dns}..."
        io.add_setting "dns_alias", "'www.#{dns}'"
        api.create_record "#{dns}", ip
        api.create_record "www.#{dns}", ip
      else
        io.log "Creating DNS entry for #{dns}..."
        io.remove_setting "dns_alias"
        api.create_record dns, ip
      end
    rescue Webbynode::ApiClient::ApiError
      if $!.message =~ /Data has already been taken/
        io.log "The DNS entry for '#{dns}' already existed, ignoring."
      else
        io.log "Couldn't create your DNS entry: #{$!.message}"
      end
    end
  end
end
