# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Accounts do
  let(:api) { double("API") }
  let(:io)  { double("Io")}
  
  def prepare(*params)
    Webbynode::Commands::Accounts.new(*params).tap do |a|
      a.stub(:api).and_return(api)
      a.stub(:io).and_return(io)
    end
  end
  
  describe '#default' do
    subject { prepare nil }

    it "shows current account" do
      api.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
      io.should_receive(:log).with("Current account: fcoury@me.com")
      subject.execute
    end
  end
  
  describe '#list' do
    subject { prepare "list" }

    it "shows all available accounts" do
      io.should_receive(:list_files).with("#{Webbynode::Io.home_dir}/.webbynode_*").and_return(["#{Webbynode::Io.home_dir}/.webbynode_personal", "#{Webbynode::Io.home_dir}/.webbynode_biz"])
      io.should_receive(:log).with("personal")
      io.should_receive(:log).with("biz")
      subject.execute
    end
  end
  
  describe '#save' do
    subject { prepare "save", "name" }
    
    it "renames the properties file" do
      io.should_receive(:copy_file).with("#{Webbynode::Io.home_dir}/.webbynode", "#{Webbynode::Io.home_dir}/.webbynode_name")
      subject.execute
    end
  end
  
  describe '#use' do
    subject { prepare "use", "name" }
    
    it "renames the properties file" do
      io.should_receive(:copy_file).with("#{Webbynode::Io.home_dir}/.webbynode_name", "#{Webbynode::Io.home_dir}/.webbynode")
      subject.execute
    end
  end
  
  describe '#new' do
    subject { prepare "new" }
    
    it "reinitializes the account" do
      api.should_receive(:init_credentials).with(true)
      subject.execute
    end
  end
end
