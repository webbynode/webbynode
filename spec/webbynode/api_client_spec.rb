# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::ApiClient do
  let(:base_uri) { Webbynode::ApiClient.base_uri }
  let(:api)      { Webbynode::ApiClient.new }

  before(:all) do
    Webbynode::ApiClient.send(:base_uri, "https://manager.webbynode.com/api/yaml")
  end

  before(:each) do
    FakeWeb.clean_registry
  end

  describe "#init_credentials" do
    let(:io) { double("Io") }
    let(:post_result) { double(:post_result).as_null_object }

    before(:each) do
      api.stub(:io).and_return(io)
      # Webbynode::ApiClient.stub(:post => post_result)
    end

    context "when credentials file exists" do
      it "should read the credentials" do
        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(true)
        api.should_receive(:properties).and_return({:email => "fcoury@me.com", :token => "apitoken", :system => 'manager'})

        creds = api.init_credentials
        creds[:system].should == "manager"
        creds[:email].should == "fcoury@me.com"
        creds[:token].should == "apitoken"
      end

      it "should write the credentials if force is true" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies",
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        properties = {}
        properties.should_receive(:save)

        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(true)
        io.should_receive(:read_from_template)
        api.stub(:properties).and_return(properties)

        api.should_receive(:ask).once.ordered.and_return("manager")
        api.should_receive(:ask).with("Login email: ").once.ordered.and_return("login@email.com")
        api.should_receive(:ask).with("API token:   ").once.ordered.and_return("apitoken")

        io.stub(:log)

        creds = api.init_credentials(true)
        creds[:system].should == "manager"
        creds[:email].should == "login@email.com"
        creds[:token].should == "apitoken"
      end

      it "should not prompt and write the credentials if force is a Hash" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies",
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        properties = {}
        properties.should_receive(:save)

        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(true)
        api.stub(:properties).and_return(properties)

        api.should_receive(:ask).never

        creds = api.init_credentials({ :email => 'login@email.com', :token => 'apitoken', :system => 'manager' })
        creds[:system].should == "manager"
        creds[:email].should == "login@email.com"
        creds[:token].should == "apitoken"
      end
    end

    context "when credentials doesn't exist" do
      it "should input the credentials" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies",
          :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

        properties = {}
        properties.should_receive(:save)

        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(false)
        io.should_receive(:read_from_template)
        api.stub(:properties).and_return(properties)

        api.should_receive(:ask).once.ordered.and_return("manager")
        api.should_receive(:ask).with("Login email: ").once.ordered.and_return("login@email.com")
        api.should_receive(:ask).with("API token:   ").once.ordered.and_return("apitoken")

        io.stub(:log)

        api.init_credentials
      end

      it "should not write the file if credentials are wrong" do
        FakeWeb.register_uri(:post, "#{base_uri}/webbies",
          :email => "fcoury@me.com", :response => read_fixture("api/webbies_unauthorized"))

        properties = {}
        properties.should_receive(:save).never

        io.should_receive(:file_exists?).with("#{ENV['HOME']}/.webbynode").and_return(false)
        io.should_receive(:read_from_template)
        api.stub(:properties).and_return(properties)

        api.should_receive(:ask).once.ordered.and_return("manager")
        api.should_receive(:ask).with("Login email: ").once.ordered.and_return("login@email.com")
        api.should_receive(:ask).with("API token:   ").once.ordered.and_return("apitoken")

        io.stub(:log)

        lambda { api.init_credentials }.should raise_error(Webbynode::ApiClient::Unauthorized, "You have provided the wrong credentials")
      end
    end
  end
end
