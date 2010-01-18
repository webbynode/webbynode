require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'wn')

describe Wn do
  
  describe "initialization" do
    before do
      @wn = Wn::App.new("init", "2.2.2.2", "test.webbynode.com")
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
      @wn.options[1].should eql("test.webbynode.com")
    end
    
    it "should display the help text when no arguments are provided" do
      @wn = Wn::App.new
      @wn.should_receive(:log_and_exit).with(@wn.read_template('help'))
      @wn.stub!(:send)
      @wn.execute
    end
  end

  describe "execution" do
    before do
      @wn = Wn::App.new("init", "2.2.2.2", "test.webbynode.com")
    end
    
    it "should execute the given command" do
      @wn.should_receive(:send).with("init")
      @wn.execute
    end
  end
  
  describe "commands" do    
    describe "init" do
      before do
        @wn = Wn::App.new("init", "2.2.2.2", "test.webbynode.com")
      end
      
      it "should execute the init command" do
        @wn.should_receive(:send).with("init")
        @wn.execute
      end
      
      
      
    end
  end

end