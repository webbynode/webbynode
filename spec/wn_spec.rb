# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')


describe Webbynode do
  
  describe "initialization" do
    before do
      @wn = Wn::App.new(["init", "2.2.2.2", "test.webbynodeqwerty.com"])
      @wn.stub!(:git_init)
      @wn.stub!(:send)
    end
    
    it "should convert arguments into an array" do
      Wn::App.new('init', '2.2.2.2')
    end
    
    it "should have parse and execute methods" do
      @wn.should respond_to(:parse)
      @wn.should respond_to(:execute)
    end
    
    it "should parse the command and arguments" do
      @wn.execute
      @wn.command.should eql("init")
      @wn.options[0].should eql("2.2.2.2")
      @wn.options[1].should eql("test.webbynodeqwerty.com")
    end
    
    it "should display the help text when no arguments are provided" do
      @wn = Wn::App.new
      @wn.should_receive(:log_and_exit).at_least(:once).with(@wn.read_template('help'))
      @wn.stub!(:send)
      @wn.execute
    end
    
    it "should not log and exit if the initial command is provided" do
      @wn.should_not_receive(:log_and_exit)
      @wn.execute
    end
  end

  describe "execution" do
    before do
      @wn = Wn::App.new("init", "2.2.2.2", "test.webbynodeqwerty.com")
    end
    
    it "should execute the given command" do
      @wn.should_receive(:send).with("init")
      @wn.execute
    end
  end
  
  describe "parser" do
    before do
      @wn = Wn::App.new("remote", "ls -la")
      @wn.stub!(:run).and_return(true)
    end
    
    it "should parse the .git/config file and set the remote_ip" do
      File.should_receive(:open).with(".git/config").and_return(read_fixture("git/config/210.11.13.12"))
      ip = @wn.parse_remote_ip
      ip.should == "210.11.13.12"
    end
    
    it "should parse the options correctly" do
      @wn.parse
      @wn.command.should == "remote"
      @wn.options[0].should == "ls -la"
    end
    
    it "should parse the .git/config file" do
      File.should_receive(:open).at_least(:once).with(".git/config").and_return(read_fixture('git/config/67.23.79.32'))
      File.should_receive(:open).at_least(:once).with(".pushand").and_return(read_fixture('pushand'))
      @wn.execute
      @wn.remote_ip.should == "67.23.79.32"
    end
    
    it "should parse the .git/config file for another ip" do
      File.should_receive(:open).with(".git/config").and_return(read_fixture('git/config/67.23.79.31'))
      File.should_receive(:open).at_least(:once).with(".pushand").and_return(read_fixture('pushand'))
      @wn.execute
      @wn.remote_ip.should == "67.23.79.31"
    end
    
    it "should parse the application name from the .pushand file" do
      File.should_receive(:open).with(".git/config").and_return(read_fixture('git/config/67.23.79.31'))
      File.should_receive(:open).at_least(:once).with(".pushand").and_return(read_fixture('pushand'))      
      @wn.execute
      @wn.remote_app_name.should eql('test.webbynodeqwerty.com')
    end
  end
  
  def parse_pushand(file)
    File.open(file).each_line do |line|
      return $1 if line =~ /^phd $0 (.+)$/
    end
  end
  
  describe "commands" do    
    describe "init" do
      before do
        @wn = Wn::App.new("init", "2.2.2.2", "test.webbynodeqwerty.com")
        @wn.stub!(:run)
        @wn.stub!(:create_file)
        @wm.stub!(:log)
      end
      
      it "should be available" do
        @wn.should respond_to(:init)
      end
      
      it "should execute the init command" do
        @wn.should_receive(:send).with("init")
        @wn.execute
      end
      
      it "should check if the .pushand/gitignore files exist. and if the .git directory is present." do
        @wn.should_receive(:file_exists).exactly(:once).with(".gitignore")
        @wn.should_receive(:file_exists).exactly(:once).with(".pushand")
        @wn.should_receive(:dir_exists).at_least(:once).with(".git")
        @wn.execute
      end
      
      it "should initialize git for webbynode" do
        @wn.should_receive(:git_init).with('2.2.2.2')
        @wn.execute
      end
      
      it "should run 4 git commands" do
        @wn.stub!(:dir_exists).at_least(:once).with(".git").and_return(true)
        @wn.should_receive(:run).at_least(:once).with(/git remote add webbynode git@(.+):(.+)/)
        @wn.should_receive(:run).at_least(:once).with(/git add ./)
        @wn.should_receive(:run).at_least(:once).with(/git commit -m "Initial Webbynode Commit"/)
        @wn.execute
      end
      
      it "should initialize git for webbynode if the .git directory does not exist" do
        @wn.stub!(:dir_exists).with(".git").and_return(false)
        @wn.should_receive(:run).at_least(:once).with("git init")
        @wn.execute
      end
      
      it "should not initialize git for Webbynode if the .git directory already exists" do
        @wn.stub!(:dir_exists).with(".git").and_return(true)
        @wn.should_not_receive(:run).with("git init")
      end
      
    end
        
    describe "push" do
      before do
        @wn = Wn::App.new("push", "2.2.2.2", "test.webbynodeqwerty.com")
        @wn.stub!(:run).and_return(true)
      end
      
      it "should be available" do
        @wn.should respond_to(:push)
      end
      
      it "should check if the .git directory exists" do
        @wn.should_receive(:dir_exists).exactly(:once).with(".git")
        @wn.execute
      end
      
      it "should log a message if the .git directory does not exist" do
        @wn.stub!(:dir_exists).and_return(false)
        @wn.should_receive(:log).with("Not an application or missing initialization. Use 'webbynode init'.")
        @wn.execute
      end
      
      it "should always log a message at least once" do
        @wn.should_receive(:log).with(/Publishing (.+) to Webbynode.../)
        @wn.execute
      end
      
      it "should execute the push command" do
        @wn.should_receive(:run).with("git push webbynode master")
        @wn.execute
      end
    end
    
    describe "remote" do
      before do
        @wn = Wn::App.new("remote", "ls -la")
        @wn.stub!(:run).and_return(true)
      end
      
      it "should be available" do
        @wn.should respond_to(:remote)
      end
      
      it "should display help instructions if no remote command is given" do
        @wn = Wn::App.new("remote")
        @wn.should_receive(:log_and_exit).at_least(:once).with(@wn.read_template('help'))
        @wn.execute
        @wn.options.should be_empty
      end
      
      it "should have one option" do
        @wn.execute
        @wn.options.count.should eql(1)
      end
      
      it "should parse the .git/config folder and retrieve the Webby IP" do
        @wn.should_receive(:parse_remote_ip)
        @wn.execute
      end
      
      it "should parse the .pushand file and retrieve the remote app name" do
        @wn.should_receive(:parse_pushand)
        @wn.execute
      end
      
      # it "should establish a connection to the remote server using SSH" do
      #   @wn.should_receive(:parse_remote_ip).with('fixtures/git/config/210.11.13.12').and_return('210.11.13.12')
      #   @wn.execute
      #   @wn.remote_ip.should eql('210.11.13.12')
      # end
      
    end
  end
end