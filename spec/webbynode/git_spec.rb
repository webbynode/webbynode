# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Git do
  def should_raise_when_response(exception, command, response, &blk)
    io_handler = mock("io")
    io_handler.should_receive(:exec).with(command).and_return(response)

    git = Webbynode::Git.new
    git.should_receive(:io).and_return(io_handler)
    lambda { yield git }.should raise_error(exception)
  end

  def should_raise(exception, command, &blk)
    should_raise_when_response exception, command, 
      "fatal: remote webbynode already exists.", &blk
  end

  def should_raise_giterror(command, &blk)
    should_raise_when_response Webbynode::GitError, command, 
      "/private/tmp/other/.git: Permission denied", &blk
  end

  def should_raise_notgitrepo(command, &blk)
    should_raise_when_response Webbynode::GitNotRepoError, command, 
      "fatal: Not a git repository (or any of the parent directories): .git", &blk
  end
  
  it "should have an io instance" do
    Webbynode::Git.new.io.class.should == Webbynode::Io
  end
  
  describe "#delete_remote" do
    it "executes remote rm command for the specificed remote" do
      git = Webbynode::Git.new
      git.should_receive(:exec).with("git remote rm webbynode")
      git.delete_remote("webbynode")
    end
    
    it "should raise an error if the specified remote doesn't exist'" do
      git = Webbynode::Git.new
      git.should_receive(:exec).with("git remote rm webbynode").and_yield("error: Could not remove config section 'remote.other'")
      lambda { git.delete_remote("webbynode") }.should raise_error(Webbynode::GitRemoteCouldNotRemoveError, "error: Could not remove config section 'remote.other'")
    end
  end
  
  describe "#remote_exists?" do
    it "returns false when git is not present" do
      git = Webbynode::Git.new
      git.should_receive(:present?).any_number_of_times.and_return(false)
      git.remote_exists?("anything").should be_false
    end
    
    it "returns false if no matching remote found" do
      git = Webbynode::Git.new
      git.should_receive(:present?).any_number_of_times.and_return(true)
      git.should_receive(:parse_config).and_return({'remote'=>{"webbynode"=>"something"}})
      git.remote_exists?("anything").should be_false
    end
    
    it "returns true if a matching remote found" do
      git = Webbynode::Git.new
      git.should_receive(:present?).any_number_of_times.and_return(true)
      git.should_receive(:parse_config).and_return({'remote'=>{"webbynode"=>"something"}})
      git.remote_exists?("webbynode").should be_true
    end
  end
  
  describe "#present?" do
    it "should be true if folder .git exists" do
      io_handler = mock("io")
      io_handler.should_receive(:directory?).with(".git").and_return(true)
    
      git = Webbynode::Git.new
      git.should_receive(:io).and_return(io_handler)
      git.should be_present
    end

    it "should be false if folder .git doesn't exist" do
      io_handler = mock("io")
      io_handler.should_receive(:directory?).with(".git").and_return(false)

      git = Webbynode::Git.new
      git.should_receive(:io).and_return(io_handler)
      git.should_not be_present
    end
  end
  
  describe "#clean?" do
    context "when git repo is clean" do
      it "should return true" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git status").and_return(read_fixture('git/status/clean'))

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.should be_clean
      end
    end

    context "when git repo is dirty" do
      it "should return false" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git status").and_return(read_fixture('git/status/dirty'))

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.should_not be_clean
      end
    end
  end
  
  describe "#add_git_init" do
    context "when sucessful" do
      it "should create .gitignore from the template" do
        io = double("io")
        io.should_receive(:create_from_template).with(".gitignore", "gitignore")
        
        git = Webbynode::Git.new
        git.stub(:io).and_return(io)
        git.add_git_ignore
      end
    end
  end
  
  describe "#init" do
    context "when successful" do
      it "should return true" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git init").and_return("Initialized empty Git repository in /Users/fcoury/tmp/.git/")

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.init.should be_true
      end
    end
    
    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        should_raise_notgitrepo("git init") { |git| git.init }
      end

      it "should raise a generic Git error if there's another error creating the repo" do
        should_raise_giterror("git init") { |git| git.init }
      end
    end
  end
  
  describe "#add_remote" do
    context "when successfull" do
      it "should create a new remote" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with("git remote add webbynode git@1.2.3.4:the_repo").and_return("")

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.add_remote("webbynode", "1.2.3.4", "the_repo").should be_true
      end
    end
    
    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        should_raise_notgitrepo("git remote add other git@5.6.7.8:a_repo") { |git| git.add_remote("other", "5.6.7.8", "a_repo") }
      end
    
      it "should return raise exception if the remote already exists" do
        should_raise(Webbynode::GitRemoteAlreadyExistsError, "git remote add other git@5.6.7.8:a_repo") { |git| 
          git.add_remote("other", "5.6.7.8", "a_repo")
        }
      end  
      
      it "should raise a generic Git error when another error occurs" do
        should_raise_giterror("git remote add other git@5.6.7.8:a_repo") { |git| git.add_remote("other", "5.6.7.8", "a_repo") }
      end
    end
  end
  
  describe "#add" do
    context "when successfull" do
      it "should add objects to git" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git add the_file')
      
        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.add("the_file")
      end

      it "should handle adding multiple files" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git add one_file/ other_file/')
      
        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.add("one_file/ other_file/")
      end
    end
    
    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        should_raise_notgitrepo("git add .") { |git| git.add(".") }
      end

      it "should raise a generic Git error when another error occurs" do
        should_raise_giterror("git add something") { |git| git.add("something") }
      end
    end
  end

  describe "#commit" do
    context "when successfull" do
      it "should add objects to git" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git commit -m "Commit comment"').and_return("[master (root-commit) 8f590c7] Commit comment
         43 files changed, 8445 insertions(+), 0 deletions(-)")

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.commit("Commit comment")
      end
      
      it "should escape double quotes" do
        io_handler = mock("io")
        io_handler.should_receive(:exec).with('git commit -m "Commiting \"the comment\""').and_return("[master (root-commit) 8f590c7] Commiting \"the comment\"
         43 files changed, 8445 insertions(+), 0 deletions(-)")

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        git.commit('Commiting "the comment"')
      end
    end
    
    context "when unsuccessfull" do
      it "should raise exception if not a git repo" do
        should_raise_giterror("git add .") { |git| git.add(".") }
      end
    end
  end
  
  describe "#remote_webbynode?" do
    context "when successful" do
      it "should check if webbynode has been initialized inside of an existing git repository" do
        io_handler = mock("Io")
        io_handler.as_null_object
      
        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        io_handler.should_receive(:exec).with('git remote').and_return('origin\nwebbynode')
        git.remote_webbynode?.should be_true
      end
    end
    
    context "when unsuccessful" do
      it "should not contain remote webbynode" do
        io_handler = mock("Io")
        io_handler.as_null_object

        git = Webbynode::Git.new
        git.should_receive(:io).and_return(io_handler)
        io_handler.should_receive(:exec).with('git remote').and_return('origin')
        git.remote_webbynode?.should be_false
      end
    end
  end
  
  describe "#parse_config" do
    context "when successful" do
      it "git should be present" do
        io_handler = mock("Io")
        io_handler.as_null_object
        
        git = Webbynode::Git.new
        git.should_receive(:io).any_number_of_times.and_return(io_handler)
        git.stub!(:remote_webbynode?).and_return(true)
        git.should_receive(:present?).and_return(true)
        File.should_receive(:open).exactly(:once).with(".git/config").and_return(read_fixture('git/config/config'))
        git.parse_config
      end
      
      it "should open the git configuration file and parse it" do
        io_handler = mock("io")
        io_handler.as_null_object
        
        File.should_receive(:open).exactly(:once).with(".git/config").and_return(read_fixture('git/config/config'))
        git = Webbynode::Git.new
        git.stub!(:remote_webbynode?).and_return(true)
        git.should_receive(:io).any_number_of_times.and_return(io_handler)
        git.parse_config
      end
    
      it "should open the git configuration file and parse it only once" do
        io_handler = mock("io")
        io_handler.as_null_object

        File.should_receive(:open).exactly(:once).with(".git/config").and_return(read_fixture('git/config/config'))
        git = Webbynode::Git.new
        git.stub!(:remote_webbynode?).and_return(true)
        git.should_receive(:io).any_number_of_times.and_return(io_handler)
        5.times {git.parse_config}
      end
      
      it "should handle .git/config" do
        io_handler = mock("io")
        io_handler.as_null_object
        
        File.should_receive(:open).exactly(:once).with(".git/config").and_return(read_fixture('git/config/config_5'))
        git = Webbynode::Git.new
        git.stub!(:remote_webbynode?).and_return(true)
        git.should_receive(:io).any_number_of_times.and_return(io_handler)
        git.parse_config
      end
    end
    
    context "when unsuccessful" do
      it "should raise an exception if the git repository does not exist." do
        git = Webbynode::Git.new
        git.should_receive(:present?).at_least(:once).and_return(false)
        git.stub!(:remote_webbynode?).and_return(true)
        File.should_not_receive(:open)
        lambda {git.parse_config}.should raise_error(Webbynode::GitNotRepoError, "Git repository does not exist.")
      end
      
      it "should raise an exception if the git repository does exist, but does not have the git remote for webbynode" do
        git = Webbynode::Git.new
        git.should_receive(:present?).at_least(:once).and_return(true)
        git.stub!(:remote_webbynode?).and_return(false)
        File.should_not_receive(:open)
        lambda {git.parse_config}.should raise_error(Webbynode::GitRemoteDoesNotExistError, "Webbynode has not been initialized.")
      end
    end
  end


  describe "#parse_remote_ip" do
    context "when successful" do
      it "should parse the configuration file" do
        git = Webbynode::Git.new
        git.should_receive(:parse_config)
        git.parse_remote_ip
      end
    
      it "should extract the remote ip from the parsed configuration file" do
        io_handler = mock("io")
        io_handler.as_null_object
      
        git = Webbynode::Git.new
        git.stub!(:remote_webbynode?).and_return(true)
        git.should_receive(:io).and_return(io_handler)
        File.should_receive(:open).exactly(:once).with(".git/config").and_return(read_fixture('git/config/config'))
        git.parse_remote_ip
        git.config.should_not be_empty
        git.remote_ip.should eql('1.2.3.4')
      end
    end
  end

end