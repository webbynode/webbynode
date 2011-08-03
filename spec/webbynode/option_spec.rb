# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Option do
  it "should require the name" do
    lambda { Webbynode::Option.new }.should raise_error
  end

  it "should parse the name" do
    Webbynode::Option.new(:param1).name.should == :param1
    Webbynode::Option.new(:param2).name.should == :param2
    Webbynode::Option.new(:'long-param2').name.should == :'long-param2'
  end
  
  describe '#name_for' do
    it "parses names with dash" do
      Webbynode::Option.name_for('--long-param2').should == 'long-param2'
    end
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
      Webbynode::Option.new(:param1, "My param", :take => :value).to_s.should == "--param1=value"
      Webbynode::Option.new(:param1, "My param").to_s.should == "--param1"
    end
  end
  
  describe "validations" do
    it "assures value is numerif if :numeric passed" do
      opt = Webbynode::Option.new(:option1, "My option", :validate => :integer )
      opt.value = 'c'
      
      error = "Invalid value 'c' for option 'option1'. It should be an integer."
      
      opt.should_not be_valid
      opt.errors.should be_include(error)
      lambda { opt.validate! }.should raise_error(Webbynode::Command::InvalidCommand, error)
    end
    
    it "assures values match if :in passed" do
      opt = Webbynode::Option.new(:option1, "My option", :validate => { :in => ['a', 'b'] })
      opt.value = 'c'
      opt.should_not be_valid
      opt.errors.should be_include("Invalid value 'c' for option 'option1'. It should be one of 'a' or 'b'.")
      lambda { opt.validate! }.should raise_error(Webbynode::Command::InvalidCommand, "Invalid value 'c' for option 'option1'. It should be one of 'a' or 'b'.")
    end
  end
end