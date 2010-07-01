# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Engine do
  let(:git) { double("Git") }
  subject do
    Class.new.tap do |c| 
      c.send(:include, Webbynode::Engines::Engine)
      c.git_excludes "config/database.yml", "db/schema.rb"
    end.new.tap do |obj|
      obj.stub!(:git).and_return(git)
    end
  end
  
  describe '#prepare' do    
    it "add nontracked entries to .gitingore" do
      git.should_receive(:remove).never
      git.should_receive(:add_to_git_ignore).with("config/database.yml")
      git.should_receive(:add_to_git_ignore).with("db/schema.rb")

      git.stub!(:tracks?).with("config/database.yml").and_return(false)
      git.stub!(:tracks?).with("db/schema.rb").and_return(false)

      subject.prepare
    end

    it "remove tracked entries and add them to .gitingore" do
      git.should_receive(:remove).with('config/database.yml')
      git.should_receive(:remove).with('db/schema.rb').never
      git.should_receive(:add_to_git_ignore).with("config/database.yml")
      git.should_receive(:add_to_git_ignore).with("db/schema.rb")

      git.stub!(:tracks?).with("config/database.yml").and_return(true)
      git.stub!(:tracks?).with("db/schema.rb").and_return(false)

      subject.prepare
    end
  end
end