# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

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
  
  describe "parsing options" do
    it "should parse arguments as params" do
      wn = Webbynode::Application.new("command", "param1", "param2")
      wn.params.should == ["param1", "param2"]
    end

    it "should parse arguments starting with -- as options" do
      wn = Webbynode::Application.new("command", "--provided=auto")
      wn.options[:provided].should == "auto"
    end
    
    it "should parse arguments without values as true" do
      wn = Webbynode::Application.new("command", "--force")
      wn.options[:force].should be_true
    end
    
    it "should provide option names as symbols" do
      wn = Webbynode::Application.new("command", "--provided=auto")
      wn.options[:provided].should == "auto"
    end
    
    it "should parse quoted values" do
      wn = Webbynode::Application.new("command", "--name=\"Felipe Coury\"")
      wn.options[:name].should == "Felipe Coury"
    end
  end
  
  describe "parsing mixed options and parameters" do
    it "should provide option names as strings and symbols" do
      wn = Webbynode::Application.new("command", "--provided=auto", "param1", "--force", "param2")
      wn.options[:provided].should == "auto"
      wn.options[:force].should be_true
      wn.params.should == ["param1", "param2"]
    end
  end

  describe "#execute" do
    it "should run the command" do
      cmd = double("cmd")
      cmd.should_receive(:run)
      
      Webbynode::Commands.should_receive(:const_get).with("DoIt").and_return(cmd)
      wn = Webbynode::Application.new("do_it")
      wn.execute
    end
    
    it "should pass the params and the options to the command" do
      cmd = double("cmd")
      cmd.should_receive(:run).with(["par1", "par2"], { :name => "Felipe" })
      
      Webbynode::Commands.should_receive(:const_get).with("DoIt").and_return(cmd)
      wn = Webbynode::Application.new("do_it", "par1", "par2", "--name=Felipe")
      wn.execute
    end
  end
end
