# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::ChangeDns do
  let(:git) { double("git").as_null_object }
  let(:io)  { double("io").as_null_object }
  let(:api) { double("api").as_null_object }

  before(:each) do
    FakeWeb.clean_registry
  end

  it "should change pushand" do
    io.should_receive(:app_name).and_return("myapp")
    io.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 myapp the.newdns.com\n", true)
    git.should_receive(:parse_remote_ip).and_return("1.2.3.4")
    api.should_receive(:create_record).with("the.newdns.com", "1.2.3.4")
    
    cmd = Webbynode::Commands::ChangeDns.new("the.newdns.com")
    cmd.should_receive(:io).any_number_of_times.and_return(io)
    cmd.should_receive(:git).any_number_of_times.and_return(git)
    cmd.should_receive(:api).any_number_of_times.and_return(api)
    
    cmd.run
  end
end