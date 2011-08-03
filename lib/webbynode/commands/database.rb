module Webbynode::Commands
  class Database < Webbynode::ActionCommand
    summary "Manages your application database"

    add_alias "db"
    allowed_actions %w(pull push config)
    
    option :debug, "Show server communication steps"
    
    requires_initialization!
    attr_reader :db
    
    def default
      io.log "Missing action: use #{"pull".color(:yellow)}, #{"push".color(:yellow)} or #{"config".color(:yellow)}. For more help use #{"#{File.basename $0} help database".color(:yellow)}."
    end
    
    def pull
      go :pull
    end
    
    def push
      go :push
    end
    
    def config
      ask_db_credentials(true)
    end
    
    def go(action)
      ask_db_credentials
      
      io.log "#{action.to_s.capitalize}ing remote data to database #{db[:name]}"
      
      db_name  = pushand.remote_db_name
      password = remote_executor.retrieve_db_password
      ip       = git.parse_remote_ip
      
      if option(:debug)
        io.log ""
        io.log "Retrieving contents from #{db_name} database in #{ip}..."
      end
      
      taps = Webbynode::Taps.new(db_name, password, io, remote_executor)
      taps.debug = option(:debug)
      begin
        io.log "Checking for dependencies..." if option(:debug)
        taps.ensure_gems!

        io.log "Starting taps in server mode..." if option(:debug)
        taps.start

        io.log "Waiting for taps to start..." if option(:debug)
        sleep 4

        io.log "Sending action #{action} with db #{db[:name]}..." if option(:debug)
        taps.send(action, :user => db[:user], 
          :password     => db[:password],
          :database     => db[:name],
          :remote_ip    => ip)
      rescue TapsError
        if $!.message =~ /LoadError: no such file to load -- (.*)/
          io.log "#{"ERROR:".color(:red)} Missing database adapter. You need to install #{$1.color(:yellow)} gem to handle your database."
        elsif $!.message =~ /Mysql::Error: Unknown database '(.*)'/
          io.log "#{"ERROR:".color(:red)} Unknown database #{$1.color(:yellow)}. Create the local database and try again."
        elsif $!.message =~ /Sequel::DatabaseConnectionError -\> Mysql::Error: (.*)/
          io.log "#{"ERROR:".color(:red)} Invalid MySQL credentials for your local database (#{$1})"
        else
          if $!.message =~ /(.*) -\> (.*)/
            io.log "#{"ERROR:".color(:red)} Unexpected error - #{$2}"
          else
            io.log "#{"ERROR:".color(:red)} Unexpected error - #{$!.message}"
          end
        end
      ensure
        io.log "Stopping taps server..."
        taps.finish
      end    
    end
    
    def query(question, default)
      answer = ask("#{question} [#{default}]: ")
      answer = default if answer.blank?
      answer
    end
    
    def retrieve_db_credentials
      @db = {
        :name => io.load_setting("database_name"),
        :user => io.load_setting("database_user"),
        :password => io.load_setting("database_password")
      }
    end
    
    def ask_db_credentials(force=false)
      retrieve_db_credentials
      
      if force || db[:name].nil?
        db[:name] = query("Database name", db[:name] || io.db_name)
        db[:user] = query("    User name", db[:user] || io.db_name)
      end
      
      save_password = false
      if force || db[:password].nil?
        db[:password] = query("     Password", "")
        save_password = ask("Save password (y/n)? ").downcase == 'y'
      end
      
      save_db_credentials(save_password)
    end
    
    def save_db_credentials(save_password)
      io.add_setting "database_name", db[:name]
      io.add_setting "database_user", db[:user]
      
      if save_password
        io.add_setting "database_password", db[:password]
      end
    end
  end
end
