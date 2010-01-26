# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Application do
  class TestCommand < Webbynode::Command
  end
  
  it "should pass no params if line empty" do
    pending
    app = Webbynode::Application.new("")
    app.params.should == []
    app.should_receive(:a)
  end
  
  describe "running commands" do
    it "should instantiate the class" do
      cmd = mock("Init")
      cmd.as_null_object
      
      Webbynode::Commands::Init.should_receive(:new).and_return(cmd)
      wn = Webbynode::Application.new("init")
      wn.execute
    end
  end
  
  describe "parsing commands" do
    context "when class doesn't exist" do
      it "should translate words separated by underscore into capitalized parts" do
        Webbynode::Commands.should_receive(:const_get).and_raise(NameError)
        
        cls = mock("UnknownClass")
        cls.should_receive(:new).never
        
        wn = Webbynode::Application.new("inexistent_command")
        Webbynode::Command.should_receive(:puts).with('Command "inexistent_command" doesn\'t exist')
        
        wn.should_receive(:command_class).never
        wn.execute
      end
    end
  end
  
  describe "#execute" do
    it "should run the command" do
      cmd = double("CommandInstance")
      cmd.should_receive(:run)
      cmd.as_null_object
      
      cmd_class = double("CommandClass")
      cmd_class.should_receive(:new).and_return(cmd)
      
      Webbynode::Commands.should_receive(:const_get).with("DoIt").and_return(cmd_class)
      wn = Webbynode::Application.new("do_it")
      wn.execute
    end
  end
end
