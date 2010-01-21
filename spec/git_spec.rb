# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode::Git do
  def should_raise_giterror(command)
    io_handler = mock("io")
    io_handler.should_receive(:exec).with(command).and_return("fatal: Not a git repository (or any of the parent directories): .git")

    git = Webbynode::Git.new(io_handler)
    lambda { yield git }.should raise_exception(Webbynode::GitNotRepoError)
  end

  describe "present?" do
    it "should be true if folder .git exists" do
      io_handler = mock("io")
      io_handler.should_receive(:directory?).with(".git").and_return(true)
    
      git = Webbynode::Git.new(io_handler)
      git.should be_present
    end

    it "should be false if folder .git doesn't exist" do
      io_handler = mock("io")
      io_handler.should_receive(:directory?).with(".git").and_return(false)

      git = Webbynode::Git.new(io_handler)
      git.should_not be_present
    end
  end
  
  describe "init" do
    context "when successfull" do
      it "should return true" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git init").and_return("Initialized empty Git repository in /Users/fcoury/tmp/.git/")

        git = Webbynode::Git.new(io_handler)
        git.init.should be_true
      end
    end
    
    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git init").and_return("fatal: Not a git repository (or any of the parent directories): .git")

        git = Webbynode::Git.new(io_handler)
        lambda { git.init }.should raise_exception(Webbynode::GitNotRepoError)
      end

      it "should raise a generic Git error if there's another error creating the repo" do
        should_raise_giterror("git init") { |git| git.init }
      end
    end
  end
  
  describe "add_remote" do
    context "when successfull" do
      it "should create a new remote" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git remote add webbynode git@1.2.3.4:the_repo").and_return("")

        git = Webbynode::Git.new(io_handler)
        git.add_remote("webbynode", "1.2.3.4", "the_repo").should be_true
      end
    end
    
    context "when unsuccessfull" do
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

      it "should raise a generic Git error when another error occurs" do
        should_raise_giterror("git remote add other git@5.6.7.8:a_repo") { |git| git.add_remote("other", "5.6.7.8", "a_repo") }
      end
    end
  end
  
  describe "add" do
    context "when successfull" do
      it "should add objects to git" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git add the_file')
      
        git = Webbynode::Git.new(io_handler)
        git.add("the_file")
      end

      it "should handle adding multiple files" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git add one_file/ other_file/')
      
        git = Webbynode::Git.new(io_handler)
        git.add("one_file/ other_file/")
      end
    end

    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git add .").and_return("fatal: Not a git repository (or any of the parent directories): .git")

        git = Webbynode::Git.new(io_handler)
        lambda { git.add(".") }.should raise_exception(Webbynode::GitNotRepoError)
      end

      it "should raise a generic Git error when another error occurs" do
        should_raise_giterror("git add something") { |git| git.add("something") }
      end
    end
  end

  describe "commit" do
    context "when successfull" do
      it "should add objects to git" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git commit -m "Commit comment"')

        git = Webbynode::Git.new(io_handler)
        git.commit("Commit comment")
      end
      
      it "should escape double quotes" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git commit -m "Commiting \"the comment\""')

        git = Webbynode::Git.new(io_handler)
        git.commit('Commiting "the comment"')
      end
    end
    
    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        should_raise_giterror("git add .") { |git| git.add(".") }
      end
    end
  end
end
