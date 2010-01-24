# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::ApiClient do
  before(:each) do
    api_class = Class.new do
      include Webbynode::ApiClient
    end
    
    @base_uri = api_class.base_uri
    @api = api_class.new
  end

  describe "#ip_for" do
    describe "when file ~/.webbynode is absent" do
      it "should call init_credentials email address and API token" do
        FakeWeb.register_uri(:post, "#{@base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        @api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        @api.ip_for("webby3067").should == "61.21.71.31"

        @api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        @api.ip_for("sandbox").should == "201.81.121.201"
      end
    end

    describe "when file ~/.webbynode is present" do
      before do
        FakeWeb.clean_registry
        FakeWeb.register_uri(:post, "#{@base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))
      end

      it "should return the IP for existing Webby hostname" do
        @api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        @api.ip_for("sandbox").should == "201.81.121.201"
      end

      it "should show an error message if the Webby does not exist for the user" do
        @api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        @api.ip_for("this_doesnt_exist").nil?.should == true
      end
    end
  end
end