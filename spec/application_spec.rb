# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode::Application do
  describe "parsing commands" do
    it "should look for a class with the name of the command" do
      Webbynode::Commands.should_receive(:const_get).with("Zap")
      wn = Webbynode::Application.new("zap")
    end
    
    it "should translate words separated by underscore into capitalized parts" do
      Webbynode::Commands.should_receive(:const_get).with("RandomThoughtsIHad")
      
      wn = Webbynode::Application.new("random_thoughts_i_had")
      wn.command_class_name.should == "RandomThoughtsIHad"
    end
    
    describe "#execute" do
      it "should run the command" do
        pending
        cmd = double("cmd")
        Class.should_receive(:for_name).with("Webbynode::Commands::DoIt").and_return(cmd)

        wn = Webbynode::Application.new("do_it")
      end
    end
  end
end
