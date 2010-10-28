# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Console do
  let(:io)      { double("Io").as_null_object }
  let(:re)      { double("RemoteExecutor").as_null_object }
  let(:server)  { double("Server").as_null_object }
  
  subject do
    server.stub!(:application_pushed?).and_return(true)
    
    Webbynode::Commands::Console.new.tap do |cmd|
      cmd.stub!(:io).and_return(io)
      cmd.stub!(:remote_executor).and_return(re)
      cmd.stub!(:server).and_return(server)
    end  
  end
  
  it "works with Rails 3" do
    ssh = double("Ssh")
    io.should_receive(:log).with("Connecting to Rails console...")
    io.should_receive(:load_setting).with('engine').and_return('rails3')
    re.should_receive(:ssh).and_return(ssh)
    ssh.should_receive(:console)
    
    subject.execute
  end
  
  it "fails with other engines" do
    ssh = double("Ssh")
    io.should_receive(:load_setting).with('engine').and_return('rails')
    io.should_receive(:log).with("Console only works for Rails 3 apps.")

    re.should_receive(:ssh).never
    ssh.should_receive(:console).never
    
    subject.execute
  end
end