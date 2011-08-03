# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Database do
  let(:io)   { double("io").as_null_object }
  let(:re)   { double("re").as_null_object }
  let(:git)  { double("git").as_null_object }
  let(:pa)   { double("pushand").as_null_object }
  let(:taps) { double("taps").as_null_object }
  
  def prepare(*params)
    Webbynode::Commands::Database.new(*params).tap do |a|
      a.stub(:io).and_return(io)
      a.stub(:remote_executor).and_return(re)
      a.stub(:git).and_return(git)
      a.stub(:pushand).and_return(pa)
    end
  end
  
  describe '#config' do
    subject { prepare "config" }

    it 'asks for credentials again, even if already provided' do
      io.should_receive(:load_setting).with("database_name").and_return("dbname")
      io.should_receive(:load_setting).with("database_password").and_return("dbpassword")
      
      io.should_receive(:db_name).any_number_of_times.and_return("myapp")
      
      subject.should_receive(:ask).with("Database name [dbname]: ").and_return("")
      subject.should_receive(:ask).with("    User name [dname]: ").and_return("")
      subject.should_receive(:ask).with("     Password []: ").and_return("")
      subject.should_receive(:ask).with("Save password (y/n)? ").and_return("y")

      subject.execute
    end
  end
  
  describe '#pull' do
    subject { prepare "pull" }

    
    context 'db failures' do
      def prepare_with_error(error)
        subject.stub(:ask_db_credentials)
        subject.stub(:db).and_return({ :name => 'db_name' })
        subject.stub(:sleep)

        Webbynode::Taps.should_receive(:new).and_return(taps)

        pa.should_receive(:remote_db_name).and_return('db_name')
        re.should_receive(:retrieve_db_password).and_return('password')
        git.should_receive(:parse_remote_ip).and_return('1.2.3.4')

        taps.should_receive(:pull).and_raise(TapsError.new(error))
      end
      
      it "shows an user friendly error message cannot connect to local database" do
        prepare_with_error "Failed to connect to database:
          Sequel::DatabaseConnectionError -> Mysql::Error: Access denied for user 'root'@'localhost' (using password: YES)"
        io.should_receive(:log).with("ERROR: Invalid MySQL credentials for your local database (Access denied for user 'root'@'localhost' (using password: YES))")

        subject.execute
      end
      
      it "shows an user friendly error for URI errors" do
        prepare_with_error "Failed to connect to database:
          URI::InvalidURIError -> the scheme mysql does not accept registry part: root:P@ssw0rd@localhost (or bad hostname?)."
        io.should_receive(:log).with("ERROR: Unexpected error - the scheme mysql does not accept registry part: root:P@ssw0rd@localhost (or bad hostname?).")

        subject.execute
      end
        
      it "shows an user friendly error message when a MySQL database doesn't exist" do
        prepare_with_error "Failed to connect to database:\n          Sequel::DatabaseConnectionError -> Mysql::Error: Unknown database 'r3app'"
        io.should_receive(:log).with("ERROR: Unknown database r3app. Create the local database and try again.")

        subject.execute
      end
      
      it "shows an user friendly error message when an adapter is not present" do
        prepare_with_error "Failed to connect to database:\n        Sequel::AdapterNotFound -> LoadError: no such file to load -- mysql"
        io.should_receive(:log).with("ERROR: Missing database adapter. You need to install mysql gem to handle your database.")

        subject.execute
      end
    end
    
    it "asks the local database credentials and name" do
      io.should_receive(:load_setting).with("database_name").and_return(nil)
      io.should_receive(:load_setting).with("database_password").and_return(nil)
      
      io.should_receive(:db_name).any_number_of_times.and_return("myapp")
      
      subject.should_receive(:ask).with("Database name [myapp]: ").and_return("")
      subject.should_receive(:ask).with("    User name [myapp]: ").and_return("")
      subject.should_receive(:ask).with("     Password []: ").and_return("")
      subject.should_receive(:ask).with("Save password (y/n)? ").and_return("y")
      
      subject.ask_db_credentials
    end
    
    context "when user doesn't authorize" do
      it "stores all data but password" do
        io.should_receive(:load_setting).with("database_name").and_return(nil)
        io.should_receive(:load_setting).with("database_password").and_return(nil)
        
        io.should_receive(:db_name).any_number_of_times.and_return("myapp")

        subject.should_receive(:ask).with("Database name [myapp]: ").and_return("")
        subject.should_receive(:ask).with("    User name [myapp]: ").and_return("user")
        subject.should_receive(:ask).with("     Password []: ").and_return("password")

        io.should_receive(:add_setting).with("database_name", "myapp")
        io.should_receive(:add_setting).with("database_user", "user")
        io.should_receive(:add_setting).with("database_password", "password").never
        subject.should_receive(:ask).with("Save password (y/n)? ").and_return("n")

        subject.ask_db_credentials
      end
    end
    
    context "when user authorizes" do
      it "stores the password" do
        io.should_receive(:load_setting).with("database_name").and_return(nil)
        io.should_receive(:load_setting).with("database_password").and_return(nil)
        
        io.should_receive(:db_name).any_number_of_times.and_return("myapp")

        subject.should_receive(:ask).with("Database name [myapp]: ").and_return("")
        subject.should_receive(:ask).with("    User name [myapp]: ").and_return("user")
        subject.should_receive(:ask).with("     Password []: ").and_return("password")
        subject.should_receive(:ask).with("Save password (y/n)? ").and_return("y")

        io.should_receive(:add_setting).with("database_password", "password")

        subject.ask_db_credentials
      end
    end
    
    context "when password not stored" do
      it "prompts for the password again" do
        io.should_receive(:load_setting).with("database_password").and_return(nil)

        io.should_receive(:load_setting).with("database_name").and_return("dbname")
        io.should_receive(:load_setting).with("database_user").and_return("user")

        subject.should_receive(:ask).with("     Password []: ").and_return("password")
        subject.should_receive(:ask).with("Save password (y/n)? ").and_return("n")
        subject.ask_db_credentials
      end
    end
    
    context "when password is stored" do
      it "doesn't prompt for password again" do
        io.should_receive(:load_setting).with("database_password").and_return("password")

        io.should_receive(:load_setting).with("database_name").and_return("dbname")
        io.should_receive(:load_setting).with("database_user").and_return("user")

        subject.should_receive(:ask).with("     Password []: ").never
        subject.should_receive(:ask).with("Save password (y/n)? ").never
        subject.ask_db_credentials
      end
    end
    
    describe "#pull" do
      it "executes taps" do
        
      end
    end
  end
end