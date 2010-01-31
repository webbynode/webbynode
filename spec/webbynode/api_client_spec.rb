# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::ApiClient do
  let(:base_uri) { Webbynode::ApiClient.base_uri }
  let(:api)      { Webbynode::ApiClient.new }
  
  before(:each) do
    FakeWeb.clean_registry
  end
  
  describe "#create_record" do
    it "should raise an exception if the domain is inactive" do
      api.should_receive(:zones).and_return({"another.com." => {:id => 21, :status => "Inactive"}})
      api.should_receive(:create_zone).never
      api.should_receive(:create_a_record).never
      
      lambda { api.create_record("yes.another.com", "10.0.0.0") }.should raise_error(Webbynode::ApiClient::InactiveZone, "another.com.")
    end

    it "should create the domain, when inexistent" do
      api.should_receive(:zones).and_return({})
      api.should_receive(:create_zone).with("newdomain.com.").and_return({:id => 20, :status => 'Active'})
      api.should_receive(:create_a_record).with(20, "new", "212.10.20.10", "new.newdomain.com")
      
      api.create_record("new.newdomain.com", "212.10.20.10")
    end

    it "should retrieve the domains, when inexistent" do
      api.should_receive(:zones).and_return({"mydomain.com.br." => {:id => 21, :status => 'Active'}})
      api.should_receive(:create_a_record).with(21, "new", "212.10.20.10", "new.mydomain.com.br")
      
      api.create_record("new.mydomain.com.br", "212.10.20.10")
    end
  end
  
  describe "#zones" do
    it "should return all the zones" do
      FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/dns", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns"))
      
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      api.zones["rubyista.info."][:domain].should == "rubyista.info."
      api.zones["webbyapp.com."][:domain].should == "webbyapp.com."
    end
  end
  
  describe "#create_zone" do
    it "should create a new zone and a new A record" do
      FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/dns", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns"))
        
      FakeWeb.register_uri(:post, 
        "#{Webbynode::ApiClient.base_uri}/dns/new?zone[ttl]=86400&zone[domain]=newzone.com.", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns_new_zone"))
     
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      api.create_zone("newzone.com.")[:id].should == 1045
    end
  end
  
  describe "#create_a_record" do
    it "should create a new A record" do
      FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/dns", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns"))
        
      FakeWeb.register_uri(:post, 
        "#{Webbynode::ApiClient.base_uri}/dns/14/records/new?record[data]=200.100.200.100&record[type]=A&record[name]=xyz", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns_a_record"))
     
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      api.create_a_record(14, "xyz", "200.100.200.100", "xyz.rubyista.info")[:id].should == 7360
    end

    it "raise an exception upon errors" do
      FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/dns", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns"))
        
      FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/dns/14/records/new?record[data]=200.100.200.100&record[type]=A&record[name]=xyz", 
        :email => "fcoury@me.com", :response => read_fixture("api/dns_a_record_error"))
     
      api.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      lambda { 
        api.create_a_record(14, "xyz", "200.100.200.100", "xyz.rubyista.info") 
      }.should raise_error(Webbynode::ApiClient::ApiError, "No DNS entry for id 99999")
    end
  end

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

  describe "when unauthorized" do
    it "should raise an error" do
      FakeWeb.register_uri(:post, "#{base_uri}/webbies", 
        :email => "fcoury@me.com", :response => read_fixture("api/webbies_unauthorized"))

      api = Webbynode::ApiClient.new
      api.should_receive(:credentials).and_return({:email => "fcoury@me.com"})
      lambda { api.ip_for("sandbox") }.should raise_error(Webbynode::ApiClient::Unauthorized, "You have provided the wrong credentials")
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
        FakeWeb.register_uri(:post, "#{base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(false)
        io.should_receive(:create_file).with("#{ENV['HOME']}/.webbynode", "email = login@email.com\ntoken = apitoken\n")
        
        api.should_receive(:ask).with("Login email: ").once.ordered.and_return("login@email.com")
        api.should_receive(:ask).with("API token:   ").once.ordered.and_return("apitoken")
        
        api.init_credentials
      end

      it "should not write the file if credentials are wrong" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies", 
          :email => "fcoury@me.com", :response => read_fixture("api/webbies_unauthorized"))

        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(false)
        io.should_receive(:create_file).never
        
        api.should_receive(:ask).with("Login email: ").once.ordered.and_return("login@email.com")
        api.should_receive(:ask).with("API token:   ").once.ordered.and_return("apitoken")
        
        lambda { api.init_credentials }.should raise_error(Webbynode::ApiClient::Unauthorized, "You have provided the wrong credentials")
      end
    end
  end
end