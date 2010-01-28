# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Alias do

  let(:a) { Webbynode::Commands::Alias.new("add", "ls -la") }
  let(:io) { double('io').as_null_object }

  before(:each) do
    a.should_receive(:io).any_number_of_times.and_return(io)
  end
  
  it "should have a constant pointing at the aliases file" do
    Webbynode::Commands::Alias::File.should eql(".webbynode/aliases")
  end
  
  describe "params" do
    it "should parse the commands" do
      a.execute
      a.action.should eql("add")
      a.command.should eql("ls -la")
    end
  end
  
  describe "aliases file availability" do
    context "when the aliases file is not present" do
      it "should create it" do
        io.should_receive(:file_exists?).with(Webbynode::Commands::Alias::File).and_return(false)
        io.should_receive(:exec).with("touch #{Webbynode::Commands::Alias::File}")
        a.execute
      end
    end
    
    context "when the aliases file is present" do
      it "should not create it, nor overwrite it" do
        io.should_receive(:file_exists?).with(Webbynode::Commands::Alias::File).and_return(true)
        io.should_not_receive(:exec).with("touch #{Webbynode::Commands::Alias::File}")
        a.execute
      end
    end
  end
  
  describe "aliases file interaction" do
    context "when writing to the file" do
      
    end
  end
  
end