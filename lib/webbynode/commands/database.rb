module Webbynode::Commands
  class Database < Webbynode::ActionCommand
    summary "Manages your application database"
    add_alias "db"
    allowed_actions %w(pull push)
    
    requires_initialization!
    attr_reader :db
    
    def pull
      go :pull
    end
    
    def push
      go :push
    end
    
    def go(action)
      ask_db_credentials
      
      io.log "#{action.to_s.capitalize}ing remote data to database #{db[:name]}"
      
      db_name  = pushand.remote_db_name
      password = remote_executor.retrieve_db_password
      ip       = git.parse_remote_ip

      taps = Webbynode::Taps.new(db_name, password, io, remote_executor)
      begin
        taps.start
        sleep 4
        taps.send(action, :user => db[:user], 
          :password     => db[:password],
          :database     => db[:name],
          :remote_ip    => ip)
      ensure
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
    
    def ask_db_credentials
      retrieve_db_credentials
      
      unless db[:name]
        db[:name] = query("Database name", io.db_name)
        db[:user] = query("    User name", io.db_name)
      end
      
      save_password = false
      unless db[:password]
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
