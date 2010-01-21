# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::InitCommand do
  def run_with(git_handler)
    command = Webbynode::InitCommand.new("1.2.3.4")
    command.stub(:git).and_return(git_handler)
    command.run
  end
  
  it "should output usage if no params given" do
    command = Webbynode::InitCommand.new(nil)
    command.run
    command.output.should =~ /Usage: webbynode init \[webby\]/
  end
  
  it "should create a new git repo when one is not present" do
    git_handler = mock("git_handler")
    git_handler.should_receive(:present?).and_return(false)
    git_handler.should_receive(:init)
    git_handler.as_null_object
    
    run_with(git_handler)
  end

  it "should add a new remote after creating the git repo" do
    git_handler = mock("git_handler")
    git_handler.should_receive(:present?).and_return(false)
    git_handler.should_receive(:add_remote).with("webbynode", "1.2.3.4")
    git_handler.as_null_object

    run_with(git_handler)
  end
  
  it "should create the initial commit after creating a new git repo" do
    git_handler = mock("git_handler")
    git_handler.should_receive(:present?).and_return(false)
    git_handler.should_receive(:add).with(".")
    git_handler.should_receive(:commit).with("Initial commit")
    git_handler.as_null_object

    run_with(git_handler)
  end

  it "should add a new remote when git is already created" do
    git_handler = mock("git_handler")
    git_handler.should_receive(:present?).and_return(true)
    git_handler.should_receive(:add_remote).with("webbynode", "1.2.3.4")
    git_handler.as_null_object

    run_with(git_handler)
  end

  it "should not create a commit if git repo is already created" do
    git_handler = mock("git_handler")
    git_handler.should_receive(:present?).and_return(true)
    git_handler.should_receive(:commit).never
    git_handler.as_null_object

    run_with(git_handler)
  end
  
  it "should try to add a remote even if the repo is created" do
    git_handler = mock("git_handler")
    git_handler.should_receive(:present?).and_return(true)
    git_handler.should_receive(:add_remote)
    git_handler.as_null_object

    run_with(git_handler)
  end
end
