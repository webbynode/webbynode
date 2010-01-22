# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Application do
  describe "parsing commands" do
    it "should look for a class with the name of the command" do
      Webbynode::Commands.should_receive(:const_get).with("Zap")
      wn = Webbynode::Application.new("zap")
      wn.parse_command
    end
    
    context "when class exists" do
      it "should translate words separated by underscore into capitalized parts" do
        Webbynode::Commands.should_receive(:const_get).with("RandomThoughtsIHad")

        wn = Webbynode::Application.new("random_thoughts_i_had")
        wn.parse_command
        wn.command_class_name.should == "RandomThoughtsIHad"
      end
    end

    context "when class doesn't exist" do
      it "should translate words separated by underscore into capitalized parts" do
        Webbynode::Commands.should_receive(:const_get).and_raise(NameError)
        
        wn = Webbynode::Application.new("inexistent_command")
        wn.should_receive(:puts).with('Command "inexistent_command" doesn\'t exist')
        wn.parse_command
      end
    end
  end
  
  describe "#execute" do
    it "should run the command" do
      cmd = double("CommandInstance")
      cmd.should_receive(:run)
      
      cmd_class = double("CommandClass")
      cmd_class.should_receive(:new).and_return(cmd)
      
      Webbynode::Commands.should_receive(:const_get).with("DoIt").and_return(cmd_class)
      wn = Webbynode::Application.new("do_it")
      wn.execute
    end
  end
end
