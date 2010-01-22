# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Command do
  describe "parsing options" do
    it "should parse arguments as params" do
      cmd = Webbynode::Command.new("param1", "param2")
      cmd.params.should == ["param1", "param2"]
    end
  
    it "should parse arguments starting with -- as options" do
      cmd = Webbynode::Command.new("--provided=auto")
      cmd.options[:provided].should == "auto"
    end
    
    it "should parse arguments without values as true" do
      wn = Webbynode::Command.new("command", "--force")
      wn.options[:force].should be_true
    end
    
    it "should provide option names as symbols" do
      wn = Webbynode::Command.new("command", "--provided=auto")
      wn.options[:provided].should == "auto"
    end
    
    it "should parse quoted values" do
      wn = Webbynode::Command.new("--name=\"Felipe Coury\"")
      wn.options[:name].should == "Felipe Coury"
    end
  end
  
  describe "parsing mixed options and parameters" do
    it "should provide option names as strings and symbols" do
      wn = Webbynode::Command.new("--provided=auto", "param1", "--force", "param2")
      wn.options[:provided].should == "auto"
      wn.options[:force].should be_true
      wn.params.should == ["param1", "param2"]
    end
  end
end