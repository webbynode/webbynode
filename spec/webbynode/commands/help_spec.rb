# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Help do
  it "should print the usage, the options and the parameters for a command" do
    CommandHelp = Class.new(Webbynode::Command)
    CommandHelp.summary "Provides help"
    CommandHelp.parameter :name, "My name"
    CommandHelp.parameter :age, "My age"
    CommandHelp.option :force, "Should I force?"
    
    CommandHelp.should_receive(:usage).and_return("usage")
    CommandHelp.should_receive(:params_help).and_return("params")
    CommandHelp.should_receive(:options_help).and_return("options")

    cmd = Webbynode::Commands::Help.new("command_help")
    cmd.run
    
    stdout =~ /Provides help/
    stdout =~ /usage/
    stdout =~ /params/
    stdout =~ /options/
  end

  it "should print only the usage, when no commands or params" do
    AnotherCommandHelp = Class.new(Webbynode::Command)
    AnotherCommandHelp.summary "Provides even more help"

    AnotherCommandHelp.should_receive(:summary_help).twice.and_return("Provides even more help")
    AnotherCommandHelp.should_receive(:usage).and_return("usage")
    AnotherCommandHelp.should_receive(:params_help).never
    AnotherCommandHelp.should_receive(:options_help).never

    cmd = Webbynode::Commands::Help.new("another_command_help")
    cmd.run
    
    stdout =~ /Provides even more help/
    stdout =~ /summary/
    stdout =~ /usage/
    stdout =~ /params/
    stdout =~ /options/
  end
  
  it "shows an error when command not found" do
    cmd = Webbynode::Commands::Help.new("i_dont_exist")
    cmd.run
    
    stdout.should =~ /Command "i_dont_exist" doesn't exist/
  end
end