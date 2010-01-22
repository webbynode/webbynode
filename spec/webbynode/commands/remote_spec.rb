# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Remote do
  
  def load_all_mocks
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
 
  before do
    load_all_mocks
  end
 
  context "when successful" do    
    it "should receive at least one option when passing in the remote command" do
      @remote = Webbynode::Commands::Remote.new('ls')
      @remote.params.should eql(['ls'])
    end
    
    it "multiple options will be joined together if multiple options are provided" do
      @remote = Webbynode::Commands::Remote.new('ls -la')
      @remote.params.should eql(['ls -la'])
    end
    
    it "should establish a connection with the server" do
      @re.should_receive(:exec).with("ls -la")
      @remote.run
    end
    
    it "should consider all parameters a single command" do
      re = mock("RemoteExecutor")
      re.as_null_object
      re.should_receive(:exec).with("these are the params")

      cmd = Webbynode::Commands::Remote.new('these', 'are', 'the', 'params')
      cmd.should_receive(:remote_executor).any_number_of_times.and_return(re)
      cmd.should_receive(:git).any_number_of_times.and_return(@git)
      cmd.should_receive(:pushand).any_number_of_times.and_return(@pushand)
      cmd.run
    end
    
    it "should parse the git config file for the server ip" do
      @git.should_receive(:parse_remote_ip).and_return('1.2.3.4')
      @remote.run
    end
    
    it "should initialize the remote executor with an IP" do
      @git.should_receive(:parse_remote_ip).and_return('5.6.7.8')
      @re.should_receive(:new).with('5.6.7.8')
      @remote.run
    end
    
    it "should parse the pushand file for the application folder name on the remote server" do
      @pushand.should_receive(:parse_remote_app_name).and_return("dummy_app")
      @remote.run
    end

  end
  
  context "when unsuccesful" do    
    it "should raise an error if no options are provided" do
      @remote = Webbynode::Commands::Remote.new
      @remote.params.should be_empty
      @re.should_not_receive(:exec)
      lambda { @remote.run }.should raise_error(Webbynode::Commands::NoOptionsProvided,
        'No remote options were provided.')
    end
    
    context "from a webbynode uninitialized application" do
      before do
        load_all_mocks
      end
      
      it "should not have a git repository" do
        @git.should_receive(:present?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::GitNotRepoError,
          "Could not find a git repository.")
      end
      
      it "should not have webbynode git remote" do
        @git.should_receive(:remote_present?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::GitRemoteDoesNotExistError,
          "Webbynode has not been initialized for this git repository.")
      end
      
      it "should not have a pushand file" do
        @pushand.should_receive(:present?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::PushAndFileNotFound,
          "Could not find .pushand file, has Webbynode been initialized for this repository?")
      end
      
      it "should not have the application pushed to the server" do
        @pushand.should_receive(:parse_remote_app_name).and_return('bdd.webbynode.com')
        @re.should_receive(:application_exists?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::ApplicationNotDeployed,
          "Before being able to run commands from your Webby, you must first push it.")
      end
    end
    
  end
end