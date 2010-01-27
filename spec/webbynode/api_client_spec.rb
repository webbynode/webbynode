# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::ApiClient do
  let(:base_uri) { Webbynode::ApiClient.base_uri }
  let(:api)      { Webbynode::ApiClient.new }

  describe "#ip_for" do
    describe "when file ~/.webbynode is absent" do
      it "should call init_credentials email address and API token" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("webby3067").should == "61.21.71.31"
      end

      it "should return the correct ip" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("sandbox").should == "201.81.121.201"
      end
    end

    describe "when file ~/.webbynode is present" do
      before do
        FakeWeb.clean_registry
        FakeWeb.register_uri(:post, "#{base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))
      end

      it "should return the IP for existing Webby hostname" do
        api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("sandbox").should == "201.81.121.201"
      end

      it "should show an error message if the Webby does not exist for the user" do
        api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("this_doesnt_exist").nil?.should == true
      end
    end
  end
  
  describe "#init_credentials" do
    let(:io) { double("Io") }

    before(:each) do
      api.should_receive(:io).any_number_of_times.and_return(io)
    end
    
    context "when credentials file exists" do
      it "should read the credentials" do
        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(true)
        io.should_receive(:read_config).with("#{ENV['HOME']}/.webbynode").and_return({:email => "fcoury@me.com", :token => "apitoken"})

        creds = api.init_credentials
        creds[:email].should == "fcoury@me.com"
        creds[:token].should == "apitoken"
      end
    end

    context "when credentials doesn't exist" do
      it "should input the credentials" do
        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(false)
        io.should_receive(:create_file).with("#{ENV['HOME']}/.webbynode", "email = login@email.com\ntoken = apitoken\n")
        
        api.should_receive(:ask).with("Login email: ").once.ordered.and_return("login@email.com")
        api.should_receive(:ask).with("API token:   ").once.ordered.and_return("apitoken")
        
        api.init_credentials
      end
    end
  end
end