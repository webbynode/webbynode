# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Command do
  describe "resolving commands" do
    it "should allow adding aliases to child classes" do
      class Zap < Webbynode::Command
        add_alias "zip"
      end
      
      Webbynode::Commands.should_receive(:const_get).with("Zap")
      Webbynode::Command.for("zip")
    end
    
    it "should look for a class with the name of the command" do
      Webbynode::Commands.should_receive(:const_get).with("Zap")
      Webbynode::Command.for("zap")
    end
    
    context "when class exists" do
      it "should translate words separated by underscore into capitalized parts" do
        Webbynode::Commands.should_receive(:const_get).with("RandomThoughtsIHad")
        Webbynode::Command.for("random_thoughts_i_had")
      end
    end
  end
  
  describe "#command" do
    it "should return the string representation of the command" do
      AwfulCommand = Class.new(Webbynode::Command)
      AwfulCommand.new.command.should == "awful_command"
      Amazing = Class.new(Webbynode::Command)
      Amazing.new.command.should == "amazing"
      SomeStrangeStuff = Class.new(Webbynode::Command)
      SomeStrangeStuff.new.command.should == "some_strange_stuff"
    end
  end
  
  describe "help for commands" do
    class NewCommand < Webbynode::Command
      description "Initializes the current folder as a deployable application"
      parameter :webby, String, "Name or IP of the Webby to deploy to"
      parameter :dns, String, "The DNS used for this application", :required => false
      
      option :passphrase, String, "If present, passphrase will be used when creating a new SSH key", :value => :words
    end
    
    before(:each) do
      @cmd = NewCommand.new
    end
    
    it "should provide help for parameters" do
      @cmd.help.should =~ /Usage: wn new_command webby \[dns\] \[options\]/
      @cmd.help.should =~ /Parameters:/
      @cmd.help.should =~ /    webby                       Name or IP of the Webby to deploy to/
      @cmd.help.should =~ /    dns                         The DNS used for this application, optional/
      @cmd.help.should =~ /Options:/
      @cmd.help.should =~ /    --passphrase=words          If present, passphrase will be used when creating a new SSH key/
    end
  end
  
  describe "parsing options" do
    it "should parse arguments as params" do
      cmd = Webbynode::Command.new("param1", "param2")
      cmd.params.should == ["param1", "param2"]
    end
  
    it "should parse arguments starting with -- as options" do
      cmd = Webbynode::Command.new("--provided=auto")
      cmd.options[:provided].should == "auto"
    end
    
    it "should parse arguments without values as true" do
      wn = Webbynode::Command.new("command", "--force")
      wn.options[:force].should be_true
    end
    
    it "should provide option names as symbols" do
      wn = Webbynode::Command.new("command", "--provided=auto")
      wn.options[:provided].should == "auto"
    end
    
    it "should parse quoted values" do
      wn = Webbynode::Command.new("--name=\"Felipe Coury\"")
      wn.options[:name].should == "Felipe Coury"
    end
  end
  
  describe "parsing mixed options and parameters" do
    it "should provide option names as strings and symbols" do
      wn = Webbynode::Command.new("--provided=auto", "param1", "--force", "param2")
      wn.options[:provided].should == "auto"
      wn.options[:force].should be_true
      wn.params.should == ["param1", "param2"]
    end
  end
end