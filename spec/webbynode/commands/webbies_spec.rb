# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Webbies do
  before(:each) do
    FakeWeb.clean_registry
  end

  it "should provide a list with all the Webbies and its status" do
    # FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/webbies", 
    #   :email => "fcoury@me.com", :response => read_fixture("api/webbies"))
    
    webby1 = Webbynode::Webby.new
    webby1.name = "sandbox"
    webby1.ip = "201.81.121.201"
    webby1.node = "miami-b15"
    webby1.plan = "plan1"
    webby1.status = "on"

    webby2 = Webbynode::Webby.new
    webby2.name = "webby3067"
    webby2.ip = "61.21.71.31"
    webby2.node = "miami-b02"
    webby2.plan = "plan2"
    webby2.status = "off"

    api = Webbynode::ApiClient.new
    api.stub(:properties)
    api.stub(:credentials)
    api.stub(:webbies => { "sandbox" => webby1, "webby3067" => webby2 })
    
    cmd = Webbynode::Commands::Webbies.new
    cmd.should_receive(:api).and_return(api)
    cmd.execute
    
    stdout.should =~ /sandbox/
    stdout.should =~ /201\.81\.121\.201/
    stdout.should =~ /miami-b15/
    stdout.should =~ /webby3067/
    stdout.should =~ /61\.21\.71\.31/
    stdout.should =~ /miami-b02/
  end
end