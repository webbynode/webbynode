# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::RemoteExecutor do
  before(:each) do
    @ssh = mock("ssh")
    
    @re = Webbynode::RemoteExecutor.new("2.2.2.2")
    @re.should_receive(:ssh).any_number_of_times.and_return(@ssh)
  end
  
  describe "#exec" do
    it "should execute the raw command on the server" do
      @ssh.should_receive(:execute).with("the same string I pass", false, false)
      @re.exec "the same string I pass"
    end
  end
  
  describe "#create_folder" do
    it "should create the folder on the server" do
      @ssh.should_receive(:execute).with("mkdir -p /var/new_folder")
      @re.create_folder "/var/new_folder"
    end
  end
end