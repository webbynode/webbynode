# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Ssh do
  let(:server) { double("server") }
  
  subject do
    Webbynode::Commands::Ssh.new
  end
  
  it "runs ssh using the git user" do
    subject.should_receive(:server).and_return(server)
    server.should_receive(:ssh)
    subject.execute
  end
end