# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::AddKey do
  let(:server) { double("server") }
  
  it "should have a constant pointing to the ssh key location" do
    LocalSshKey.should == "#{ENV['HOME']}/.ssh/id_rsa.pub"
  end
  
  it "should be aliased to addkey" do
    Webbynode::Commands.should_receive(:const_get).with("AddKey")
    Webbynode::Command.for("addkey")
  end
  
  context "when successful" do
    it "should upload the local ssh key into the server" do
      server.should_receive(:add_ssh_key).with(LocalSshKey, nil)

      cmd = Webbynode::Commands::AddKey.new
      cmd.should_receive(:server).any_number_of_times.and_return(server)
      cmd.execute
    end

    it "should create an ssh key with a provided passphrase" do
      server.should_receive(:add_ssh_key).with(LocalSshKey, "my_passphrase")

      cmd = Webbynode::Commands::AddKey.new("--passphrase=my_passphrase")
      cmd.should_receive(:server).any_number_of_times.and_return(server)
      cmd.execute
    end
  end

  context "when unsuccessful" do
    let(:cmd) { Webbynode::Commands::AddKey.new }
    let(:io)  { double("Io").as_null_object }  
    
    before(:each) do
      cmd.should_receive(:io).any_number_of_times.and_return(io)
    end
    
    it "should report an error if the ssh key could not be added due to invalid authentication" do
      server.should_receive(:add_ssh_key).and_raise(Webbynode::InvalidAuthentication)

      cmd.should_receive(:server).any_number_of_times.and_return(server)
      io.should_receive(:log).with("Could not connect to webby: invalid authentication.", true)
      cmd.execute
    end

    it "should report an error if the ssh key could not be added due to a permission error" do
      server.should_receive(:add_ssh_key).and_raise(Webbynode::PermissionError)

      cmd.should_receive(:server).any_number_of_times.and_return(server)
      io.should_receive(:log).with("Could not create an SSH key: permission error.", true)
      cmd.execute
    end
  end
end