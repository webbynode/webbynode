module Webbynode::Commands
  class Database < Webbynode::ActionCommand
    summary "Manages your application database"
    add_alias "db"
    allowed_actions %w(pull push)
    
    requires_initialization!
    attr_reader :db_credentials
    
    def pull
      ask_db_credentials
      
      io.log "Pulling remote data to database #{db_credentials[:name]}"
    end
    
    private
    
    def query(question, default)
      answer = ask("#{question} [#{default}]: ")
      answer = default if answer.blank?
      answer
    end
    
    def retrieve_db_credentials
      @db_credentials = {
        :name => io.load_setting("database_name"),
        :user => io.load_setting("database_user"),
        :password => io.load_setting("database_password")
      }
    end
    
    def ask_db_credentials
      retrieve_db_credentials
      
      unless db_credentials[:name]
        db_credentials[:name] = query("Database name", io.db_name)
        db_credentials[:user] = query("    User name", io.db_name)
      end
      
      save_password = false
      unless db_credentials[:password]
        db_credentials[:password] = query("     Password", "")
        save_password = ask("Save password (y/n)? ").downcase == 'y'
      end
      
      save_db_credentials(save_password)
    end
    
    def save_db_credentials(save_password)
      io.add_setting "database_name", db_credentials[:name]
      io.add_setting "database_user", db_credentials[:user]
      
      if save_password
        io.add_setting "database_password", db_credentials[:password]
      end
    end
  end
end
