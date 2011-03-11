# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Database do
  let(:io) { double("io").as_null_object }
  
  def prepare(*params)
    Webbynode::Commands::Database.new(*params).tap do |a|
      a.stub(:io).and_return(io)
    end
  end
  
  describe '#pull' do
    subject { prepare "pull" }
    
    it "asks the local database credentials and name" do
      io.should_receive(:load_setting).with("database_name").and_return(nil)
      io.should_receive(:load_setting).with("database_password").and_return(nil)
      
      io.should_receive(:db_name).any_number_of_times.and_return("myapp")
      
      subject.should_receive(:ask).with("Database name [myapp]: ").and_return("")
      subject.should_receive(:ask).with("    User name [myapp]: ").and_return("")
      subject.should_receive(:ask).with("     Password []: ").and_return("")
      subject.should_receive(:ask).with("Save password (y/n)? ").and_return("y")
      
      io.should_receive(:log).with("Pulling remote data to database myapp")
      
      subject.execute
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

        subject.execute
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

        subject.execute
      end
    end
    
    context "when password not stored" do
      it "prompts for the password again" do
        io.should_receive(:load_setting).with("database_password").and_return(nil)

        io.should_receive(:load_setting).with("database_name").and_return("dbname")
        io.should_receive(:load_setting).with("database_user").and_return("user")

        subject.should_receive(:ask).with("     Password []: ").and_return("password")
        subject.should_receive(:ask).with("Save password (y/n)? ").and_return("n")
        subject.execute
      end
    end
    
    context "when password is stored" do
      it "doesn't prompt for password again" do
        io.should_receive(:load_setting).with("database_password").and_return("password")

        io.should_receive(:load_setting).with("database_name").and_return("dbname")
        io.should_receive(:load_setting).with("database_user").and_return("user")

        subject.should_receive(:ask).with("     Password []: ").never
        subject.should_receive(:ask).with("Save password (y/n)? ").never
        subject.execute
      end
    end
  end
end