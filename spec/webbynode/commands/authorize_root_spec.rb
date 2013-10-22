# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::AuthorizeRoot do
  let(:server) { double("server") }

  it "is aliased to authorizeroot" do
    Webbynode::Commands.should_receive(:const_get).with("AuthorizeRoot")
    Webbynode::Command.for("authorizeroot")
  end

  it "is aliased to authroot" do
    Webbynode::Commands.should_receive(:const_get).with("AuthorizeRoot")
    Webbynode::Command.for("authroot")
  end

  context "when successful" do
    it "uploads the local ssh key into the server's root folder" do
      server.should_receive(:add_ssh_root_key).with(LocalSshKey, nil)

      cmd = Webbynode::Commands::AuthorizeRoot.new
      cmd.stub(:server).and_return(server)
      cmd.execute
    end

    it "should create an ssh key with a provided passphrase" do
      server.should_receive(:add_ssh_root_key).with(LocalSshKey, "my_passphrase")

      cmd = Webbynode::Commands::AuthorizeRoot.new("--passphrase=my_passphrase")
      cmd.stub(:server).and_return(server)
      cmd.execute
    end
  end

  context "when unsuccessful" do
    let(:cmd) { Webbynode::Commands::AuthorizeRoot.new }
    let(:io)  { double("Io").as_null_object }

    before(:each) do
      cmd.stub(:io).and_return(io)
    end

    it "reports an error if the ssh key could not be added due to invalid authentication" do
      server.should_receive(:add_ssh_root_key).and_raise(Webbynode::InvalidAuthentication)

      cmd.stub(:server).and_return(server)
      io.should_receive(:log).with("Could not connect to webby: invalid authentication.", true)
      cmd.execute
    end

    it "should report an error if the ssh key could not be added due to a permission error" do
      server.should_receive(:add_ssh_root_key).and_raise(Webbynode::PermissionError)

      cmd.stub(:server).and_return(server)
      io.should_receive(:log).with("Could not create an SSH key: permission error.", true)
      cmd.execute
    end
  end
end
