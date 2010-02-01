# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Webbies do
  before(:each) do
    FakeWeb.clean_registry
  end

  it "should provide a list with all the Webbies and its status" do
    FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/webbies", 
      :email => "fcoury@me.com", :response => read_fixture("api/webbies"))
    
    
  end
end