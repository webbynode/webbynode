# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Guides do
  it "opens Rapp guides in browser" do
    Launchy.should_receive(:open).with('http://wbno.de/rapp')
    subject.execute
  end
end