# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Help do
  
  it "should display the help page" do
    help = Webbynode::Commands::Help.new
    help.should_receive(:read_template).with('help')
    help.should_receive(:log_and_exit)
    help.execute
  end

end