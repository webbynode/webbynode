# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Open do
  let(:re)      { double("RemoteExecutor").as_null_object }
  let(:io)      { double("Io").as_null_object }

  subject do
    Webbynode::Commands::Open.new.tap do |cmd|
      cmd.stub!(:remote_executor).and_return(re)
      cmd.stub!(:io).and_return(io)
    end
  end

  it "detects the app URL and opens in browser" do
    io.should_receive(:app_name).and_return('myapp')
    re.should_receive(:exec).with("test -f /var/webbynode/mappings/myapp.conf && cat /var/webbynode/mappings/myapp.conf", false).and_return("www.cade.com\n")
    Launchy.should_receive(:open).with('http://www.cade.com')
    
    subject.execute
  end

  it "shows an error message and exit if app not found remotely" do
    io.should_receive(:app_name).and_return('myapp')
    re.should_receive(:exec).with("test -f /var/webbynode/mappings/myapp.conf && cat /var/webbynode/mappings/myapp.conf", false).and_return("")
    Launchy.should_receive(:open).never
    io.should_receive(:log).with("Application not found or not deployed.")
    
    subject.execute
  end
end