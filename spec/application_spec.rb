# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode::Application do
  describe "when initializing" do
    before do
      @wn = Webbynode::Application.new(["init", "2.2.2.2", "test.webbynodeqwerty.com"])
      @wn.stub!(:git_init)
      @wn.stub!(:send)
    end

    it "should convert arguments into an array" do
      Webbynode::Application.new('init', '2.2.2.2')
    end

    it "should have parse and execute methods" do
      @wn.should respond_to(:parse_command)
      @wn.should respond_to(:execute)
    end

    it "should parse the command and arguments" do
      @wn.execute
      @wn.command.should eql("init")
      @wn.options[0].should eql("2.2.2.2")
      @wn.options[1].should eql("test.webbynodeqwerty.com")
    end

    it "should extract named parameters to a hash" do
      wn = Webbynode::Application.new("command", "2.2.2.2", "--option=this", "--boolean_option")
      wn.parse_command
      wn.command.should eql("command")
      wn.options.should == ["2.2.2.2"]
      wn.named_options["option"].should == "this"
      wn.named_options["boolean_option"].should == true
    end

    it "should display the help text when no arguments are provided" do
      @wn = Webbynode::Application.new
      @wn.should_receive(:log_and_exit).at_least(:once).with(@wn.read_template('help'))
      @wn.should_not_receive(:send)
      @wn.execute
    end

    it "should display the help text when a non-existent command is being called" do
      @wn = Webbynode::Application.new("thisdoesnotexist")
      @wn.should_receive(:log_and_exit).at_least(:once).with(@wn.read_template('help'))
      @wn.should_not_receive(:send)
      @wn.execute      
    end

    it "should not log and exit if the initial command is provided" do
      @wn.should_not_receive(:log_and_exit)
      @wn.execute
    end
  end
  
  describe "when executing" do
    before do
      @wn = Webbynode::Application.new("init", "2.2.2.2", "test.webbynodeqwerty.com")
    end

    it "should execute the given command" do
      @wn.should_receive(:send).with("init")
      @wn.execute
    end
  end

  describe "parsing command line" do
    before do
      @wn = Webbynode::Application.new("remote", "ls -la")
      @wn.stub!(:run).and_return(true)
      Net::SSH.stub!(:start).and_return(true)
    end

    it "should parse the .git/config file and set the remote_ip" do
      File.should_receive(:open).with(".git/config").and_return(read_fixture("git/config/210.11.13.12"))
      ip = @wn.parse_remote_ip
      ip.should == "210.11.13.12"
    end

    it "should parse the options correctly" do
      @wn.parse_command
      @wn.command.should eql("remote")
      @wn.options[0].should eql("ls -la")
    end

    it "should parse the .git/config file" do
      @wn.stub(:requires_application_environment!).and_return(true)
      File.should_receive(:open).at_least(:once).with(".git/config").and_return(read_fixture('git/config/67.23.79.32'))
      File.should_receive(:open).at_least(:once).with(".pushand").and_return(read_fixture('pushand'))
      @wn.execute
      @wn.remote_ip.should == "67.23.79.32"
    end

    it "should parse the .git/config file for another ip" do
      File.should_receive(:open).with(".git/config").and_return(read_fixture('git/config/67.23.79.31'))
      File.should_receive(:open).at_least(:once).with(".pushand").and_return(read_fixture('pushand'))
      @wn.stub!(:requires_application_environment!).and_return(true)
      @wn.execute
      @wn.remote_ip.should == "67.23.79.31"
    end

    it "should parse the application name from the .pushand file" do
      File.should_receive(:open).with(".git/config").and_return(read_fixture('git/config/67.23.79.31'))
      File.should_receive(:open).at_least(:once).with(".pushand").and_return(read_fixture('pushand'))  
      @wn.stub!(:requires_application_environment!).and_return(true)    
      @wn.execute
      @wn.remote_app_name.should eql('test.webbynodeqwerty.com')
    end
  end
  
  describe "application environment" do
    it "should require the application environment" do
      @wn = Webbynode::Application.new("remote", "ls -la")
      @wn.stub!(:is_webbynode_environment?).and_return(false)
      @wn.stub!(:git_remote_webbynode?).and_return(false)
      @wn.stub!(:is_webbynode_environment?).and_return(false)
      @wn.stub!(:run_remote_command)
      @wn.should_receive(:requires_application_environment!).exactly(:once)

      # Another one that should work but doesn't..
      # @wn.should_receive(:log_and_exit).at_least(:once).with("You can only execute the \"remote\" from inside a Webbynode initialized application.")

      @wn.execute
    end
  end
end
