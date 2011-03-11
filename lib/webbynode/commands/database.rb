module Webbynode::Commands
  class Database < Webbynode::ActionCommand
    summary "Manages your application database"
    add_alias "db"
    allowed_actions %w(pull push)
    
    requires_initialization!
    attr_reader :db_credentials
    
    def pull
      ask_db_credentials unless retrieve_db_credentials
      
      io.log "Pulling remote data to database #{db_credentials[:name]}"
    end
    
    private
    
    def query(question, default)
      answer = ask("#{question} [#{default}]: ")
      answer = default if answer.nil? or answer.blank?
      answer
    end
    
    def retrieve_db_credentials
      return false unless io.load_setting "database_name"
      @db_credentials = {
        :name => io.load_setting("database_name"),
        :user => io.load_setting("database_user"),
        :password => io.load_setting("database_password")
      }
    end
    
    def ask_db_credentials
      @db_credentials = {
        :name         => query("Database name", io.db_name),
        :user         => query("User name", io.db_name),
        :password     => query("Password", "")
      }
      save_db_credentials
    end
    
    def save_db_credentials
      io.add_setting "database_name", db_credentials[:name]
      io.add_setting "database_user", db_credentials[:user]
      io.add_setting "database_password", db_credentials[:password]
    end
  end
end
