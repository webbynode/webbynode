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
      AwfulCommand.command.should == "awful_command"
      Amazing = Class.new(Webbynode::Command)
      Amazing.command.should == "amazing"
      SomeStrangeStuff = Class.new(Webbynode::Command)
      SomeStrangeStuff.command.should == "some_strange_stuff"
    end
  end
  
  describe "array of parameters" do
    class ArrayCommand < Webbynode::Command
      description "Initializes the current folder as a deployable application"
      parameter :params, Array, "Name or IP of the Webby to deploy to"      
      option :passphrase, String, "If present, passphrase will be used when creating a new SSH key", :take => :words
    end
    
    it "should return an array of parameters" do
      cmd = ArrayCommand.new("a", "b", "--passphrase=abc", "c", "d")
      cmd.params.first.value.should == ["a", "b", "c", "d"]
      cmd.option(:passphrase).should == "abc"
    end
  end
  
  describe "with no params" do
    class Brief < Webbynode::Command
    end
    
    it "should refuse any param" do
      cmd = Brief.new("test")
      cmd.run
      stdout.should =~ /command 'brief' takes no parameters/
    end
  end
  
  describe "help for commands" do
    class NewCommand < Webbynode::Command
      description "Initializes the current folder as a deployable application"
      parameter :webby, String, "Name or IP of the Webby to deploy to"
      parameter :dns, String, "The DNS used for this application", :required => false
      
      option :passphrase, String, "If present, passphrase will be used when creating a new SSH key", :take => :words
    end
    
    before(:each) do
      @cmd = NewCommand.new("what!")
    end
    
    it "should provide help for parameters" do
      NewCommand.help.should =~ /Usage: webbynode new_command webby \[dns\] \[options\]/
      NewCommand.help.should =~ /Parameters:/
      NewCommand.help.should =~ /    webby                       Name or IP of the Webby to deploy to/
      NewCommand.help.should =~ /    dns                         The DNS used for this application, optional/
      NewCommand.help.should =~ /Options:/
      NewCommand.help.should =~ /    --passphrase=words          If present, passphrase will be used when creating a new SSH key/
    end
  end
  
  describe "parsing options" do
    it "should complain about missing params and show usage" do
      Sample = Class.new(Webbynode::Command)
      Sample.parameter :param1, "Teste"
      
      cmd = Sample.new
      cmd.run
      
      stdout.should =~ /Missing 'param1' parameter. Use "webbynode help sample" for more information./
      stdout.should =~ /Usage: webbynode sample param1/
    end
    
    it "should parse arguments as params" do
      Sample1 = Class.new(Webbynode::Command)
      Sample1.parameter :param1, ""
      Sample1.parameter :param2, ""
      
      cmd = Sample1.new("param1", "param2")
      cmd.params.first.value.should == "param1"
      cmd.params.last.value.should == "param2"
    end
  
    it "should parse arguments starting with -- as options" do
      Sample2 = Class.new(Webbynode::Command)
      Sample2.option :provided, ""
      
      cmd = Sample2.new("--provided=auto")
      cmd.option(:provided).should == "auto"
    end
    
    it "should parse arguments without values as true" do
      Sample3 = Class.new(Webbynode::Command)
      Sample3.option :force, ""
      
      wn = Sample3.new("--force")
      wn.option(:force).should be_true
    end
    
    it "should provide option names as symbols" do
      Sample4 = Class.new(Webbynode::Command)
      Sample4.option :provided, ""
      
      wn = Sample4.new("--provided=auto")
      wn.option(:provided).should == "auto"
    end
    
    it "should parse quoted values" do
      Sample5 = Class.new(Webbynode::Command)
      Sample5.option :name, ""

      wn = Sample5.new("--name=\"Felipe Coury\"")
      wn.option(:name).should == "Felipe Coury"
    end
  end
  
  describe "parsing mixed options and parameters" do
    class Cmd < Webbynode::Command
      parameter :param1, String, "param1"
      parameter :param2, String, "param2"
      option :provided, "option1"
      option :force, "option2"
    end
    
    it "should provide option names as strings and symbols" do
      wn = Cmd.new("--provided=auto", "param1", "--force", "param2")
      wn.option(:provided) == "auto"
      wn.option(:force).should be_true
      lambda { wn.option(:another) }.should raise_error(Webbynode::Command::InvalidOption)
      wn.param_values.should == ["param1", "param2"]
    end
  end
    
  describe "parsing array parameters" do
    class ArrayCmd < Webbynode::Command
      parameter :param1, String, "param1"
      parameter :param2, String, "param2"
      parameter :param_array, Array, "array"
      option :option, String, "descr"
    end
    
    it "should parse params and all remaining as the array param" do
      cmd = ArrayCmd.new("param1", "param2", "arr1", "arr2", "arr3", "arr4")
      cmd.param(:param1).should == "param1"
      cmd.param(:param2).should == "param2"
      cmd.param(:param_array).should == ["arr1", "arr2", "arr3", "arr4"]
    end

    it "should ignore options" do
      cmd = ArrayCmd.new("param1", "param2", "--option=tough", "arr1", "arr2", "arr3", "arr4")
      cmd.option(:option).should == "tough"
      cmd.param(:param1).should == "param1"
      cmd.param(:param2).should == "param2"
      cmd.param(:param_array).should == ["arr1", "arr2", "arr3", "arr4"]
    end
  end
    
  context "with a webbynode uninitialized application" do
    class NewCommand < Webbynode::Command
      requires_initialization!
    end

    before do
      command.should_receive(:remote_executor).any_number_of_times.and_return(re)
      command.should_receive(:git).any_number_of_times.and_return(git)
      command.should_receive(:io).any_number_of_times.and_return(io)
      command.should_receive(:pushand).any_number_of_times.and_return(pushand)
      command.should_receive(:server).any_number_of_times.and_return(server)
    end
    
    let(:command) { NewCommand.new("some") }
    let(:re)      { double("RemoteExecutor").as_null_object }
    let(:git)     { double("Git").as_null_object }
    let(:pushand) { double("Pushand").as_null_object }
    let(:server)  { double("Server").as_null_object }
    let(:ssh)     { double("SSh").as_null_object }
    let(:io)      { double("Io").as_null_object }
    
    it "should not have a git repository" do
      git.should_receive(:present?).and_return(false)
      lambda { command.run }.should raise_error(Webbynode::GitNotRepoError,
        "Could not find a git repository.")
    end
    
    it "should not have webbynode git remote" do
      git.should_receive(:remote_webbynode?).and_return(false)
      lambda { command.run }.should raise_error(Webbynode::GitRemoteDoesNotExistError,
        "Webbynode has not been initialized for this git repository.")
    end
    
    it "should not have a pushand file" do
      git.should_receive(:present?).and_return(true)
      io.should_receive(:directory?).with(".webbynode").and_return(true)
      pushand.should_receive(:present?).and_return(false)
      lambda { command.run }.should raise_error(Webbynode::PushAndFileNotFound,
        "Could not find .pushand file, has Webbynode been initialized for this repository?")
    end
  end
end