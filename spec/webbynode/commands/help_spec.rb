# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Help do
  it "should print the usage, the options and the parameters for a command" do
    Sample = Class.new(Webbynode::Command)
    Sample.parameter :name, "My name"
    Sample.parameter :age, "My age"
    Sample.option :force, "Should I force?"
    
    Sample.should_receive(:usage).and_return("usage")
    Sample.should_receive(:params_help).and_return("params")
    Sample.should_receive(:options_help).and_return("options")

    cmd = Webbynode::Commands::Help.new("sample")
    cmd.run
    
    stdout =~ /usage/
    stdout =~ /params/
    stdout =~ /options/
  end
end