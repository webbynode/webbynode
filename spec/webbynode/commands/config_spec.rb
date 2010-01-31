# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Config do
  let(:api) { double("ApiClient") }
  
  it "should write ~/.webbynode config file" do
    api.should_receive(:init_credentials).with({})
    
    cmd = Webbynode::Commands::Config.new
    cmd.should_receive(:api).any_number_of_times.and_return(api)
    cmd.run
  end
  
  it "should write ~/.webbynode config file" do
    api.should_receive(:init_credentials).with({ :email => "email", :token => 'token'} )
    
    cmd = Webbynode::Commands::Config.new("--email=email", "--token=token")
    cmd.should_receive(:api).any_number_of_times.and_return(api)
    cmd.run
  end
end