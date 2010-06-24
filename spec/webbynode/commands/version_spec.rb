# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Version do

  let(:version) { Webbynode::Commands::Version.new }
  let(:io) { double('io').as_null_object }

  before(:each) do
    version.should_receive(:io).any_number_of_times.and_return(io)
  end
  
  it "should return the version of the gem" do
    io.should_receive(:log).with("Rapid Deployment Gem v#{Webbynode::VERSION}", :quiet_start)
    version.execute
  end
  
end