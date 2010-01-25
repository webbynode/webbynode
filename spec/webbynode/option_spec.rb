# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Option do
  it "should require the name" do
    lambda { Webbynode::Option.new }.should raise_error
  end

  it "should parse the name" do
    Webbynode::Option.new(:param1).name.should == :param1
    Webbynode::Option.new(:param2).name.should == :param2
  end
  
  it "should parse the type, if given" do
    Webbynode::Option.new(:param1, Integer).kind.should == Integer
  end
  
  it "should assume String for the type, if none given" do
    Webbynode::Option.new(:param1).kind.should == String
    Webbynode::Option.new(:param1, "My description").kind.should == String
  end
  
  it "should parse the description" do
    Webbynode::Option.new(:param1, "My description").desc.should == "My description"
    Webbynode::Option.new(:param1, String, "My description").desc.should == "My description"
  end
  
  it "should parse the options" do
    Webbynode::Option.new(:param1, "My description", :amazing => true).options[:amazing].should be_true
  end
  
  describe "#to_s" do
    it "should parse use the name and the value option" do
      Webbynode::Option.new(:param1, "My param", :value => :value).to_s.should == "--param1=value"
      Webbynode::Option.new(:param1, "My param").to_s.should == "--param1"
    end
  end
end