# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::AddKey do
  it "should have a constant pointing to the ssh key location" do
    Webbynode::Commands::AddKey::LocalSshKey.should == "#{ENV['HOME']}/.ssh/id_rsa.pub"
  end
  
  context "when successful" do
    it "should upload the local ssh key into the server" do
      server = mock("server")
      server.should_receive(:add_ssh_key).with(Webbynode::Commands::AddKey::LocalSshKey, nil)

      cmd = Webbynode::Commands::AddKey.new
      cmd.should_receive(:server).any_number_of_times.and_return(server)
      cmd.run
    end

    it "should create an ssh key with a provided passphrase" do
      server = mock("server")
      server.should_receive(:add_ssh_key).with(Webbynode::Commands::AddKey::LocalSshKey, "my_passphrase")

      cmd = Webbynode::Commands::AddKey.new({ :passphrase => "my_passphrase" })
      cmd.should_receive(:server).any_number_of_times.and_return(server)
      cmd.run
    end
  end

  context "when unsuccessful" do
    it "should report an error if the ssh key could not be added due to invalid authentication" do
      server = mock("server")
      server.should_receive(:add_ssh_key).and_raise(Webbynode::InvalidAuthentication)

      cmd = Webbynode::Commands::AddKey.new
      cmd.should_receive(:server).any_number_of_times.and_return(server)
      cmd.should_receive(:puts).with("Could not connect to server: invalid authentication.")
      cmd.run
    end

    it "should report an error if the ssh key could not be added due to a permission error" do
      server = mock("server")
      server.should_receive(:add_ssh_key).and_raise(Webbynode::PermissionError)

      cmd = Webbynode::Commands::AddKey.new
      cmd.should_receive(:server).any_number_of_times.and_return(server)
      cmd.should_receive(:puts).with("Could not create an SSH key: permission error.")
      cmd.run
    end
  end
end