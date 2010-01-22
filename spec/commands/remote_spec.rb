# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Commands::Remote do
 
  context "when successful" do
    before do
      @re = mock("RemoteExecutor")
      @re.as_null_object
      
      @git = mock("Git")
      @git.as_null_object

      @pushand = mock("Pushand")
      @pushand.as_null_object

      @remote = Webbynode::Commands::Remote.new('ls -la')
      @remote.should_receive(:remote_executor).any_number_of_times.and_return(@re)
      @remote.should_receive(:git).any_number_of_times.and_return(@git)
      @remote.should_receive(:pushand).any_number_of_times.and_return(@pushand)
    end
    
    it "should receive at least one option when passing in the remote command" do
      @remote = Webbynode::Commands::Remote.new('ls')
      @remote.options.should eql('ls')
    end
    
    it "multiple options will be joined together if multiple options are provided" do
      @remote = Webbynode::Commands::Remote.new('ls -la')
      @remote.options.should eql('ls -la')
    end
    
    it "should establish a connection with the server" do
      @re.should_receive(:exec).with("ls -la")
      @remote.run
    end
    
    it "should parse the git config file for the server ip" do
      @git.should_receive(:parse_remote_ip).and_return('1.2.3.4')
      @remote.run
    end
    
    it "should parse the pushand file for the application folder name on the remote server" do
      @pushand.should_receive(:parse_remote_app_name).and_return("dummy_app")
      @remote.run
    end

  end
  
  context "when unsuccesful" do
    before do
      @re = mock("RemoteExecutor")
      @re.as_null_object
      
      @remote = Webbynode::Commands::Remote.new('ls -la')
      @remote.should_receive(:remote_executor).any_number_of_times.and_return(@re)
    end
    
    it "should raise an error if no options are provided" do
      @remote = Webbynode::Commands::Remote.new
      @remote.options.should be_empty
      @re.should_not_receive(:exec)
      lambda { @remote.run }.should raise_exception(Webbynode::Commands::NoOptionsProvided, 'No remote options were provided.')
    end
  end
  
end