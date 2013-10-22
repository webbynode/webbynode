# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::ChangeDns do
  let(:git) { double("git").as_null_object }
  let(:io)  { double("io").as_null_object }
  let(:api) { double("api").as_null_object }
  let(:cmd) { Webbynode::Commands::ChangeDns.new("the.newdns.com") }
  let(:pushand) { double.as_null_object }

  before(:each) do
    FakeWeb.clean_registry
    cmd.stub(:io).and_return(io)
    cmd.stub(:git).and_return(git)
    cmd.stub(:api).and_return(api)
    cmd.stub(:pushand).and_return(pushand)
  end

  it "should change pushand" do
    io.should_receive(:app_name).and_return("myapp")
    pushand.should_receive(:create!).with("myapp", "the.newdns.com")
    git.should_receive(:parse_remote_ip).and_return("1.2.3.4")
    api.should_receive(:create_record).with("the.newdns.com", "1.2.3.4")

    cmd.run
  end

  it "gives an error message when zone exists, but is inactive" do
    git.should_receive(:parse_remote_ip).and_return("1.2.3.4")
    api.should_receive(:create_record).with("the.newdns.com", "1.2.3.4").and_raise(Webbynode::ApiClient::InactiveZone.new( "the.newdns.com"))

    io.should_receive(:log).with("Changing DNS to the.newdns.com...", :quiet_start)
    io.should_receive(:log).with("Creating DNS entry for the.newdns.com...")
    io.should_receive(:log).with("Domain the.newdns.com already setup on Webbynode DNS, but it's inactive.")
    io.should_receive(:log).with("Please reactivate it and try again.")

    cmd.run
  end

  it "should give an error message if there are git changes pending" do
    git.should_receive(:clean?).and_return(false)

    cmd.run
    stdout.should =~ /Cannot change DNS because you have pending changes. Do a git commit or add changes to .gitignore./
  end

  context "when committing the DNS change" do
    it "should perform a commit of .pushand" do
      io.should_receive(:file_exists?).with(".webbynode/settings").and_return(false)
      git.should_receive(:add).with(".pushand")
      git.should_receive(:commit3).
        with("Changed DNS to \"the.newdns.com\"").
        and_return([true, "blah"])
      cmd.run
    end

    it "should perform a commit of .pushand and .webbynode/settings if the later exists" do
      io.should_receive(:file_exists?).with(".webbynode/settings").and_return(true)
      git.should_receive(:add).with(".pushand")
      git.should_receive(:add).with(".webbynode/settings")
      git.should_receive(:commit3).with("Changed DNS to \"the.newdns.com\"").and_return([true, "blah"])
      cmd.run
    end
  end

  context "when commit fails" do
    it "reports the error" do
      io.should_receive(:file_exists?).with(".webbynode/settings").and_return(false)
      git.should_receive(:add).with(".pushand")
      git.should_receive(:commit3).with("Changed DNS to \"the.newdns.com\"").and_return([false, "Some git error"])
      lambda { cmd.execute }.should raise_error(Webbynode::Command::CommandError)
    end
  end
end
