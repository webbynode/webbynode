# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Init do
  before(:each) do
    @git_handler = mock("dummy_git_handler").as_null_object
    @io_handler  = mock("dummy_io_handler").as_null_object

    @command = Webbynode::Commands::Init.new("4.3.2.1")
    @command.should_receive(:git).any_number_of_times.and_return(@git_handler) 
    @command.should_receive(:io).any_number_of_times.and_return(@io_handler)
  end
  
  it "should have a Git instance" do
    Webbynode::Commands::Init.new.git.class.should == Webbynode::Git
  end
  
  it "should output usage if no params given" do
    command = Webbynode::Commands::Init.new
    command.run
    command.output.should =~ /Usage: webbynode init \[webby\]/
  end
  
  it "should have an Io instance" do
    Webbynode::Commands::Init.new.io.class.should == Webbynode::Io
  end
  
  context "when .gitignore is not present" do
    it "should create the standard .gitignore" do
      @io_handler.should_receive(:file_exists?).with(".gitignore").and_return(false)
      @git_handler.should_receive(:add_git_ignore)
      
      @command.run
    end
  end
  
  context "when .pushand is not present" do
    it "should be created" do
      @io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      @io_handler.should_receive(:app_name).twice.and_return("mah_app")
      @io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 mah_app\n")
      
      @command.run
    end
  end
  
  context "when .pushand is present" do
    it "should not be created" do
      @io_handler.should_receive(:file_exists?).with(".pushand").and_return(true)
      @io_handler.should_receive(:create_file).never
      
      @command.run
    end
  end
  
  context "when git repo doesn't exist yet" do
    it "should create a new git repo" do
      @git_handler.should_receive(:present?).and_return(false)
      @git_handler.should_receive(:init)

      @command.run
    end
    
    it "should add a new remote" do
      @io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
      @git_handler.should_receive(:present?).and_return(false)
      @git_handler.should_receive(:add_remote).with("webbynode", "4.3.2.1", "my_app")

      @command.run
    end
    
    it "should add everything" do
      @git_handler.should_receive(:present?).and_return(false)
      @git_handler.should_receive(:add).with(".")

      @command.run
    end
  
    it "should create the initial commit" do
      @git_handler.should_receive(:present?).and_return(false)
      @git_handler.should_receive(:commit).with("Initial commit")
      
      @command.run
    end
  end

  context "when git repo is initialized" do
    it "should not create a commit" do
      @git_handler.should_receive(:present?).and_return(true)
      @git_handler.should_receive(:commit).never

      @command.run
    end

    it "should try to add a remote" do
      @git_handler.should_receive(:present?).and_return(true)
      @git_handler.should_receive(:add_remote)

      @command.run
    end
    
    it "should tell the user it's already initialized" do
      @git_handler.should_receive(:present?).and_return(true)
      @git_handler.should_receive(:add_remote).and_raise(Webbynode::GitRemoteAlreadyExistsError)
      
      @command.should_receive(:puts).with("Webbynode already initialized for this application.")
      @command.run
    end
  end
end
