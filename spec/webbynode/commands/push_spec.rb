# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Push do

  let(:push) { Webbynode::Commands::Push.new }
  let(:io) { double('io').as_null_object }

  before(:each) do
    push.should_receive(:io).any_number_of_times.and_return(io)
  end
  
  context "when the user runs the command" do
    it "should display a message that the application is being pushed to the webby" do
      io.should_receive(:log).with("Pushing application to your Webby.")
      push.stub!(:exec)
      push.execute
    end
    
    it "should push the application to the webby" do
      io.should_receive(:exec).with("git push webbynode master")
      push.execute
    end
  end
end