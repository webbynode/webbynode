# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::RemoteExecutor do
  let(:ssh) { double('Ssh').as_null_object }
  subject do
    Webbynode::RemoteExecutor.new("2.2.2.2").tap do |re|
      re.stub(:ssh).and_return(ssh)
    end
  end

  describe '#version' do
    it { subject.version('0.2.23').should == '-v=0.2.23 ' }
    it { subject.version(nil).should == '' }
  end

  describe '#gem_installed?' do
    it "returns true when gem is installed" do
      subject.should_receive(:exec).with("gem list -i -v=0.2.23 taps").and_return('true')
      subject.gem_installed?('taps', '0.2.23').should be_true
    end

    it "returns false when gem isn't installed" do
      subject.should_receive(:exec).with("gem list -i mysql").and_return('false')
      subject.gem_installed?('mysql').should be_false
    end
  end

  describe '#install_gem' do
    it "returns true when gem is successfully installed" do
      subject.should_receive(:exec).with("sudo gem install taps > /dev/null 2>1; echo $?").and_return('0')
      subject.install_gem('taps').should be_true
    end

    it "returns false when gem can't be installed" do
      subject.should_receive(:exec).with("sudo gem install mysql > /dev/null 2>1; echo $?").and_return('2')
      subject.install_gem('mysql').should be_false
    end
  end

  describe '#retrieve_db_password' do
    it "retrieves the remote db password" do
      subject.should_receive(:exec).with(%q(echo `cat /var/webbynode/templates/rails/database.yml | grep password: | tail -1 | cut -d ":" -f 2`)).and_return("password\n")
      subject.retrieve_db_password.should == "password"
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
