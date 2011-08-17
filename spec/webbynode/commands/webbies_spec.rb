# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Webbies do
  before(:each) do
    FakeWeb.clean_registry
  end

  it "should provide a list with all the Webbies and its status" do
    FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/webbies", 
      :email => "fcoury@me.com", :response => read_fixture("api/webbies"))
    
    api = Webbynode::ApiClient.new
    api.stub(:properties)
    api.stub(:credentials)
    
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