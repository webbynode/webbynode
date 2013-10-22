# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Delete do
  let(:cmd)     { Webbynode::Commands::Delete.new }
  let(:pushand) { double("PushAnd").as_null_object }
  let(:re)      { double("RemoteExecutor").as_null_object }
  let(:io)      { double("Io").as_null_object }

  def setup_mocks(cmd)
    cmd.stub(:pushand).and_return(pushand)
    cmd.stub(:remote_executor).and_return(re)
    cmd.stub(:io).and_return(io)
  end

  before do
    setup_mocks(cmd)
  end

  it "should run delete_app for the current application" do
    pushand.should_receive(:parse_remote_app_name).and_return("myapp")
    re.should_receive(:exec).with("delete_app myapp --force", true)
    cmd.should_receive(:ask).with("Do you really want to delete application myapp (y/n)? ").and_return("y")
    cmd.run
  end

  context "when pushand doesn't exist" do
    it "should poop an easter egg" do
      pushand.should_receive(:present?).and_return(false)
      io.should_receive(:log).with("Ahn!? Hello, McFly, anybody home?", true)
      cmd.stub(:ask)
      cmd.ask.stub(:downcase)
      cmd.execute
    end
  end

  context "when pushand exists" do
    it "should not poop an easter egg" do
      pushand.should_receive(:present?).and_return(true)
      io.should_not_receive(:log).with("Ahn!? Hello, McFly, anybody home?", true)
      cmd.stub(:ask)
      cmd.ask.stub(:downcase)
      cmd.execute
    end
  end

  it "should delete if user responds Y" do
    pushand.should_receive(:parse_remote_app_name).and_return("myapp")
    re.should_receive(:exec).with("delete_app myapp --force", true)
    cmd.should_receive(:ask).with("Do you really want to delete application myapp (y/n)? ").and_return("Y")
    cmd.run
  end

  it "should delete if force option is given" do
    cmd = Webbynode::Commands::Delete.new("--force")
    pushand.should_receive(:parse_remote_app_name).and_return("myapp")
    re.should_receive(:exec).with("delete_app myapp --force", true)
    setup_mocks(cmd)

    cmd.run
  end

  it "should ask for confirmation" do
    pushand.should_receive(:parse_remote_app_name).and_return("myapp")
    re.should_receive(:exec).never
    cmd.should_receive(:puts).with("Aborted.")
    cmd.should_receive(:ask).with("Do you really want to delete application myapp (y/n)? ").and_return("n")
    cmd.run
  end

  it "abort if user didn't respond y" do
    pushand.should_receive(:parse_remote_app_name).and_return("myapp")
    re.should_receive(:exec).never
    cmd.should_receive(:puts).with("Aborted.")
    cmd.should_receive(:ask).with("Do you really want to delete application myapp (y/n)? ").and_return("X")
    cmd.run
  end
end
