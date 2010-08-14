# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::RemoteExecutor do
  let(:ssh) { double('Ssh').as_null_object }
  subject do
    Webbynode::RemoteExecutor.new("2.2.2.2").tap do |re|
      re.stub!(:ssh).and_return(ssh)
    end
  end
  
  describe "#new" do
    subject { Webbynode::RemoteExecutor.new("2.1.2.2", 'user', 2020) }
    
    its(:port) { should == 2020 }
    
    it "takes an optional port as parameter" do
      Webbynode::Ssh.should_receive(:new).with("2.1.2.2", 'user', 2020).and_return(ssh)
      subject.exec "hello mom", false, false
    end
  end
  
  describe '#remote_home' do
    it "returns the home folder for the git user" do
      subject.should_receive(:exec).with('pwd').and_return("/var/rapp\n")
      subject.remote_home.should == '/var/rapp'
    end
  end
  
  describe "#exec" do
    it "raises a CommandError when connection is refused" do
      ssh.should_receive(:execute).and_raise(Errno::ECONNREFUSED)
      lambda { subject.exec "something" }.should raise_error(Webbynode::Command::CommandError, 
        "Could not connect to 2.2.2.2. Please check your settings and your network connection and try again.")
    end
    
    it "executes the raw command on the server" do
      ssh.should_receive(:execute).with("the same string I pass", false, false)
      subject.exec "the same string I pass"
    end
  end
  
  describe "#create_folder" do
    it "creates the folder on the server" do
      ssh.should_receive(:execute).with("mkdir -p /var/new_folder")
      subject.create_folder "/var/new_folder"
    end
  end
end