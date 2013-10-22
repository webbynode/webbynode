# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::PushAnd do
  before(:each) do
    @io = double(:io)
    @pushand = Webbynode::PushAnd.new
    @pushand.stub(:io).and_return(@io)
  end

  it "should have an Io instance" do
    Webbynode::PushAnd.new.io.class.should == Webbynode::Io
  end

  describe "#present?" do
    it "should return true when .pushand file is present" do
      @io.should_receive(:file_exists?).with(".pushand").and_return(true)
      @pushand.present?.should == true
    end
  end

  describe "parse_remote_app_name" do
    it "should parse the .pushand file for the app name" do
      @io.should_receive(:read_file).with(".pushand").and_return("phd $0 app_name dnsentry")
      @pushand.parse_remote_app_name.should == "app_name"
    end
  end

  describe "#create!" do
    it "creates .pushand" do
      @io.should_receive(:create_file).with(".pushand",
        "#! /bin/bash\nphd $0 app_name dns_entry\n", true)
      @pushand.create!("app_name", "dns_entry")
    end
  end
end
