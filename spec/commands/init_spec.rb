# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Commands::Init do
  def run_with(options)
    git_handler = options[:git_handler] || mock("dummy_git_handler").as_null_object
    io_handler  = options[:io_handler]  || mock("dummy_io_handler").as_null_object

    command = Webbynode::Commands::Init.new("1.2.3.4")
    command.should_receive(:git).any_number_of_times.and_return(git_handler) 
    command.should_receive(:io).any_number_of_times.and_return(io_handler)
    command.run
  end
  
  it "should output usage if no params given" do
    command = Webbynode::Commands::Init.new(nil)
    command.run
    command.output.should =~ /Usage: webbynode init \[webby\]/
  end
  
  context "when .gitignore is not present" do
    it "should create the standard .gitinit"
  end
  
  context "when .pushand is not present" do
    it "should be created"
  end
  
  context "when git repo doesn't exist yet" do
    it "should create a new git repo" do
      git_handler = mock("git_handler1")
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:init)
      git_handler.as_null_object
    
      run_with(:git_handler => git_handler)
    end
    
    it "should add a new remote" do
      io_handler = mock("io_handler")
      io_handler.should_receive(:app_name).and_return("my_app")
    
      git_handler = mock("git_handler2")
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:add_remote).with("webbynode", "1.2.3.4", "my_app")
      git_handler.as_null_object

      run_with(:git_handler => git_handler, :io_handler => io_handler)
    end
    
    it "should add everything" do
      git_handler = mock("git_handler3")
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:add).with(".")
      git_handler.as_null_object

      run_with(:git_handler => git_handler)    
    end
  
    it "should create the initial commit" do
      git_handler = mock("git_handler3")
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:commit).with("Initial commit")
      git_handler.as_null_object

      run_with(:git_handler => git_handler)
    end
  end

  context "when git repo is initialized" do
    it "should not create a commit" do
      git_handler = mock("git_handler")
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:commit).never
      git_handler.as_null_object

      run_with(:git_handler => git_handler)
    end

    it "should try to add a remote" do
      git_handler = mock("git_handler")
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:add_remote)
      git_handler.as_null_object

      run_with(:git_handler => git_handler)
    end
  end
end
