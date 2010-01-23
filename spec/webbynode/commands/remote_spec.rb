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
    
    @server = mock("Server")
    @server.as_null_object
    
    @ssh = mock("Ssh")
    @ssh.as_null_object

    @remote = Webbynode::Commands::Remote.new('ls -la')
    @remote.should_receive(:remote_executor).any_number_of_times.and_return(@re)
    @remote.should_receive(:git).any_number_of_times.and_return(@git)
    @remote.should_receive(:pushand).any_number_of_times.and_return(@pushand)
    @remote.should_receive(:server).any_number_of_times.and_return(@server)
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
      @pushand.should_receive(:parse_remote_app_name).and_return('test.webbynode.com')
      @re.should_receive(:exec).with("cd test.webbynode.com ls -la")
      @remote.run
    end
    
    it "should consider all parameters a single command" do
      @remote = Webbynode::Commands::Remote.new('these', 'are', 'the', 'params')
      @remote.should_receive(:server).any_number_of_times.and_return(@server)
      @remote.should_receive(:remote_executor).any_number_of_times.and_return(@re)
      @remote.should_receive(:git).any_number_of_times.and_return(@git)
                  
      @re.should_receive(:exec).with("cd webbynode these are the params")
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
      @remote.stub!(:validate_initialization)
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
        @git.should_receive(:remote_webbynode?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::GitRemoteDoesNotExistError,
          "Webbynode has not been initialized for this git repository.")
      end
      
      it "should not have a pushand file" do
        @pushand.should_receive(:present?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::PushAndFileNotFound,
          "Could not find .pushand file, has Webbynode been initialized for this repository?")
      end
      
      it "should not have the application pushed to the server" do
        @server.should_receive(:application_pushed?).and_return(false)
        lambda { @remote.run }.should raise_error(Webbynode::ApplicationNotDeployed,
          "Before being able to run remote commands from your Webby, you must first push your application to it.")
      end
    end
    
  end
end