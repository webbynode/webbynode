# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Manager2ApiClient do
  let(:base_uri) { Webbynode::Manager2ApiClient.base_uri }
  let(:api)      { Webbynode::Manager2ApiClient.new }
  
  before(:each) do
    FakeWeb.clean_registry
  end
  
  describe "#create_record" do
    it "should create the domain, when inexistent" do
      api.should_receive(:zones).and_return({})
      api.should_receive(:create_zone).with("newdomain.com").and_return({'id' => 20})
      api.should_receive(:create_a_record).with(20, "new", "212.10.20.10", "new.newdomain.com")
      
      api.create_record("new.newdomain.com", "212.10.20.10")
    end

    it "should retrieve the domains, when inexistent" do
      api.should_receive(:zones).and_return({"mydomain.com.br" => {'id' => 21}})
      api.should_receive(:create_a_record).with(21, "new", "212.10.20.10", "new.mydomain.com.br")
      
      api.create_record("new.mydomain.com.br", "212.10.20.10")
    end
  end
  
  describe "#zones" do
    it "should return all the zones" do
      FakeWeb.register_uri(:get, "#{Webbynode::Manager2ApiClient.base_uri}/zones.json?auth_token=", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/zones"))
      
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      api.zones["rubyista.info"]['name'].should == "rubyista.info"
      api.zones["webbyapp.com"]['name'].should == "webbyapp.com"
    end
  end
  
  describe "#create_zone" do
    it "should create a new zone and a new A record" do
      FakeWeb.register_uri(:post, "#{Webbynode::Manager2ApiClient.base_uri}/zones.json", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/zones"))
        
      FakeWeb.register_uri(:post, 
        "#{Webbynode::Manager2ApiClient.base_uri}/zones.json?zone[name]=newzone.com.", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/zones_new_zone"))
     
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      api.create_zone("newzone.com.")['id'].should == 22
    end
  end
  
  describe "#create_a_record" do
    before do
      FakeWeb.register_uri(:post, "#{Webbynode::Manager2ApiClient.base_uri}/zones.json?auth_token=", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/zones"))
    end

    it "should create a new A record" do
      FakeWeb.register_uri(:post, 
        "#{Webbynode::Manager2ApiClient.base_uri}/zones/14/records.json", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/zones_a_record"))
     
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      api.create_a_record(14, "xyz", "200.100.200.100", "xyz.rubyista.info")['id'].should == 32
    end

    it "raise an exception upon errors" do
      FakeWeb.register_uri(:post, "#{Webbynode::Manager2ApiClient.base_uri}/zones/14/records.json", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/zones_a_record_error"))
     
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      lambda { 
        api.create_a_record(14, "xyz", "200.100.200.100", "xyz.rubyista.info") 
      }.should raise_error(Webbynode::Manager2ApiClient::ApiError, "this domain was not found under your account")
    end
  end

  describe "#ip_for" do
    describe "when file ~/.webbynode is absent" do
      it "should call init_credentials email address and API token" do
        FakeWeb.register_uri(:get, "#{base_uri}/webbies.json?auth_token=", 
          :email => "fcoury@me.com", :response => read_fixture("manager2/webbies"))

        api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("webby6203.webbyapp.com").should == "192.168.183.200"
      end

      it "should return the correct ip" do
        FakeWeb.register_uri(:get, "#{base_uri}/webbies.json?auth_token=", 
          :email => "fcoury@me.com", :response => read_fixture("manager2/webbies"))

        api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("sandbox.webbyapp.com").should == "201.81.121.201"
      end
    end

    describe "when file ~/.webbynode is present" do
      before do
        FakeWeb.register_uri(:get, "#{base_uri}/webbies.json?auth_token=", 
          :email => "fcoury@me.com", :response => read_fixture("manager2/webbies"))
      end

      it "should return the IP for existing Webby hostname" do
        api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("sandbox.webbyapp.com").should == "201.81.121.201"
      end

      it "should show an error message if the Webby does not exist for the user" do
        api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
        api.ip_for("this_doesnt_exist").nil?.should == true
      end
    end
  end

  describe "when unauthorized" do
    it "should raise an error" do
      FakeWeb.register_uri(:get, "#{base_uri}/webbies.json?auth_token=", 
        :email => "fcoury@me.com", :response => read_fixture("manager2/webbies_unauthorized"))

      api = Webbynode::Manager2ApiClient.new
      api.should_receive(:credentials).and_return({:email => "fcoury@me.com"})
      lambda { api.ip_for("sandbox") }.should raise_error(Webbynode::Manager2ApiClient::Unauthorized, "You have provided the wrong credentials")
    end
  end
end