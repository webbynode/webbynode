# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode::Git do
  describe "present?" do
    it "should be true if folder .git exists" do
      io_handler = mock("io")
      io_handler.should_receive(:directory?).with(".git").and_return(true)
    
      git = Webbynode::Git.new(io_handler)
      git.present?.should == true
    end

    it "should be false if folder .git doesn't exist" do
      io_handler = mock("io")
      io_handler.should_receive(:directory?).with(".git").and_return(false)

      git = Webbynode::Git.new(io_handler)
      git.present?.should == false
    end
  end
  
  describe "init" do
    it "should create a new git repo" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with("git init")
      
      git = Webbynode::Git.new(io_handler)
      git.init
    end
    
    it "should return true if repository is created" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with("git init").and_return("Initialized empty Git repository in /Users/fcoury/tmp/.git/")
      
      git = Webbynode::Git.new(io_handler)
      git.init.should == true
    end
    
    it "should return false if there's an error creating the repo" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with("git init").and_return("/Users/fcoury/tmp/other/.git: Permission denied")
      
      git = Webbynode::Git.new(io_handler)
      git.init.should == false
    end
  end
  
  describe "add_remote" do
    it "should create a new remote" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with("git remote add webbynode git@1.2.3.4:the_repo").and_return("")
      
      git = Webbynode::Git.new(io_handler)
      git.add_remote("webbynode", "1.2.3.4", "the_repo").should == true
    end
    
    it "should raise exception if not a git repo" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with("git remote add other git@5.6.7.8:a_repo").and_return("fatal: Not a git repository (or any of the parent directories): .git")

      git = Webbynode::Git.new(io_handler)
      lambda { git.add_remote("other", "5.6.7.8", "a_repo") }.should raise_exception(Webbynode::GitNotRepoError)
    end
    
    it "should return raise exception if the remote already exists" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).and_return("fatal: remote webbynode already exists.")

      git = Webbynode::Git.new(io_handler)
      lambda { git.add_remote("other", "5.6.7.8", "a_repo") }.should raise_exception(Webbynode::GitRemoteAlreadyExistsError)
    end
  end
  
  describe "add" do
    it "should add objects to git" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with('git add the_file')
      
      git = Webbynode::Git.new(io_handler)
      git.add("the_file")
    end

    it "should specified files" do
      io_handler = mock("io")
      io_handler.should_receive(:exec).with('git add one_file/ other_file/')
      
      git = Webbynode::Git.new(io_handler)
      git.add("one_file/ other_file/")
    end
    
    it "should return false if there's an error creating the repo" do
      pending
      io_handler = mock("io")
      io_handler.should_receive(:exec).with("git remote add other git@5.6.7.8:a_repo").and_return("fatal: Not a git repository (or any of the parent directories): .git")

      git = Webbynode::Git.new(io_handler)
      git.add_remote("other", "5.6.7.8", "a_repo").should == false
    end
  end

  describe "commit" do
    it "should add objects to git" do
      pending
      io_handler = mock("io")
      io_handler.should_receive(:exec).with('git commit -m "Commit comment"')
      
      git = Webbynode::Git.new(io_handler)
      git.commit("Commit comment")
    end
  end
end
