# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Parameter do
  it "should require the name" do
    lambda { Webbynode::Parameter.new }.should raise_error
  end
  
  it "should allow setting a value" do
    param = Webbynode::Parameter.new(:param1)
    param.value = "hello"
    param.value.should == "hello"
  end

  it "should parse the name" do
    Webbynode::Parameter.new(:param1).name.should == :param1
    Webbynode::Parameter.new(:param2).name.should == :param2
  end
  
  it "should parse the type, if given" do
    Webbynode::Parameter.new(:param1, Integer).kind.should == Integer
  end
  
  it "should assume String for the type, if none given" do
    Webbynode::Parameter.new(:param1).kind.should == String
    Webbynode::Parameter.new(:param1, "My description").kind.should == String
  end
  
  it "should parse the description" do
    Webbynode::Parameter.new(:param1, "My description").desc.should == "My description"
    Webbynode::Parameter.new(:param1, String, "My description", :required => true).desc.should == "My description"
  end
  
  it "should parse the options" do
    Webbynode::Parameter.new(:param1, "My description", :required => true).options[:required].should be_true
  end
  
  it "should be required by default" do
    Webbynode::Parameter.new(:param1).should be_required
  end
  
  describe "#required?" do
    it "should be true if no param's :required is given" do
      Webbynode::Parameter.new(:param1, "My description").options[:required].should be_true
      Webbynode::Parameter.new(:param1, "My description").should be_required
    end      
   
    it "should be true if param's :required is true" do
      Webbynode::Parameter.new(:param1, "My description", :required => true).options[:required].should be_true
      Webbynode::Parameter.new(:param1, "My description", :required => true).should be_required
    end      
   
    it "should be false if param's :required is false" do
      Webbynode::Parameter.new(:param1, "My description", :required => false).options[:required].should be_false
      Webbynode::Parameter.new(:param1, "My description", :required => false).should_not be_required
    end
  end
  
  describe "#to_s" do
    it "should render as the parameter name if required" do
      Webbynode::Parameter.new(:param1).to_s.should == "param1"
    end

    it "should render on square brackets if optional" do
      par = Webbynode::Parameter.new(:param2, "some description", :required => false)
      par.should_not be_required
      par.to_s.should == "[param2]"
    end
  end
end