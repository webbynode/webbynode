# Load Webbynode Class
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'wn')
Webbynode = Wn

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
      @wn.should_receive(:log_and_exit).with(@wn.read_template('help'))
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
  
  describe "commands" do    
    describe "init" do
      before do
        @wn = Wn::App.new("init", "2.2.2.2", "test.webbynodeqwerty.com")
        @wn.stub!(:run)
        @wn.stub!(:create_file)
        @wm.stub!(:log)
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
        @wn.should_receive(:run).at_least(3).times
        @wn.execute
      end
    end
    
    describe "push" do
      before do
        @wn = Wn::App.new("push", "2.2.2.2", "test.webbynodeqwerty.com")
        @wn.stub!(:run).and_return(true)
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
  end

end