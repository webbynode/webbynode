# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode do
  describe Webbynode::Io do
    describe "create_yaml_file" do
      it "should persist a ruby variable to a YAML file" do
        mock_file = mock("yaml_file")
        mock_file.should_receive(:write).with("--- \n:teste: works\n")
      
        File.should_receive(:open).with("x.yml", "w").and_yield(mock_file)
      
        wn = Webbynode::Application.new("")
        wn.create_yaml_file "x.yml", {:teste => "works"}, false
      end
    end
  
    describe "read_yaml_file" do
      it "should read and parse a YAML file" do
        File.should_receive(:exists?).with("x.yml").and_return(true)
        File.should_receive(:read).with("x.yml").and_return("--- \n:teste: works\n")
      
        wn = Webbynode::Application.new("")
        wn.read_yaml_file("x.yml").should == {:teste => "works"}
      end
    
      it "should evaluate the block if file doesn't exist" do
        File.should_receive(:exists?).with("x.yml").and_return(false)
      
        wn = Webbynode::Application.new("")
        wn.read_yaml_file("x.yml") { "hey there!" }.should == "hey there!"
      end
    end
  end
end