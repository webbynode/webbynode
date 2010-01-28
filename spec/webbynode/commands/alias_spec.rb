# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Alias do

  let(:a) { Webbynode::Commands::Alias.new("add", "my_alias", "ls", "-la") }
  let(:io) { double('io').as_null_object }

  before(:each) do
    a.should_receive(:io).any_number_of_times.and_return(io)
    File.stub!(:read).with(Webbynode::Commands::Alias::FilePath).
      and_return(File.join(File.dirname(__FILE__), '../../fixtures/aliases'))
  end
  
  it "should have a constant pointing at the aliases file" do
    Webbynode::Commands::Alias::FilePath.should eql(".webbynode/aliases")
  end
  
  describe "params" do
    it "should parse the add commands" do
      a = Webbynode::Commands::Alias.new("add", "my_alias", "ls", "-la")
      a.stub!(:send).with("add")
      a.execute
      a.action.should eql("add")
      a.alias.should eql("my_alias")
      a.command.should eql("ls -la")
    end
    
    it "should parse the remove commands" do
      a = Webbynode::Commands::Alias.new("remove", "my_alias")
      a.stub!(:send).with("remove")
      a.execute
      a.action.should eql("remove")
      a.alias.should eql("my_alias")
      a.command.should be_blank
    end
  end
  
  describe "#exists?" do
    it "should determine whether the specified alias already exists" do
      a.exists?("my_alias").should be_false
    end
    
    it "should determine whether the specified alias already exists" do
      a.session_aliases << "[my_alias] rake db:migrate"
      a.exists?("my_alias").should be_true
    end
  end
  
  describe "#extract_command" do
    it "should extract the command from the session_aliases based on the given alias if it exists" do
      a = Webbynode::Commands::Alias.new
      a.stub!(:read_aliases_file)
      a.session_aliases << "[my_alias] rake db:migrate"
      a.extract_command('my_alias').should eql("rake db:migrate")
    end
    
    it "should return false because the requested alias does not exist" do
      a = Webbynode::Commands::Alias.new
      a.stub!(:read_aliases_file)
      a.extract_command('my_alias').should be_false
    end
  end
  
  describe "aliases file availability" do
    context "when the aliases file is not present" do
      it "should create it" do
        io.should_receive(:file_exists?).with(Webbynode::Commands::Alias::FilePath).and_return(false)
        io.should_receive(:exec).with("touch #{Webbynode::Commands::Alias::FilePath}")
        a.ensure_aliases_file_exists
      end
    end
    
    context "when the aliases file is present" do
      it "should not create it, nor overwrite it" do
        io.should_receive(:file_exists?).with(Webbynode::Commands::Alias::FilePath).and_return(true)
        io.should_not_receive(:exec).with("touch #{Webbynode::Commands::Alias::FilePath}")
        a.ensure_aliases_file_exists
      end
    end
  end
  
  describe "reading out the aliases from the file" do
    it "should read out each line that has an alias" do
      a.should_receive(:read_aliases_file)
      a.execute
    end
  end
  
  describe "aliases file interaction" do
    context "when writing to the file" do
      it "should invoke the add method" do
        a.should_receive(:send).with('add')
        a.execute
      end
      
      it "should append the new alias to the session_aliases" do
        a.should_receive(:append_alias)
        a.execute
      end
      
      it "should open the file in 'write mode' to write all aliases from session_aliases to it" do
        io.should_receive(:open_file).with(Webbynode::Commands::Alias::FilePath, "w")
        a.execute
      end
      
      it "should not add the alias to session_aliases if the command is blank" do
        a = Webbynode::Commands::Alias.new("add", "my_alias")
        a.should_receive(:io).any_number_of_times.and_return(io)
        io.should_receive(:log).with("You must provide a remote command for the alias.")
        a.execute
        a.session_aliases.size.should eql(0)
      end
      
      it "should not add the alias if it already exists" do
        a = Webbynode::Commands::Alias.new("add", "my_alias", "custom command")
        a.should_receive(:io).any_number_of_times.and_return(io)
        a.stub!(:write_aliases)
        a.stub!(:read_aliases_file)
        a.session_aliases << "[my_alias] foo"
        a.session_aliases << "[mah_alias] bar"
        io.should_receive(:log).with("You already have an alias named [my_alias].")
        a.execute
        a.should have(2).session_aliases
      end
      
      it "should not add the alias to session_aliases if the command is blank" do
        a = Webbynode::Commands::Alias.new("add", "my_alias")
        a.stub!(:write_aliases)
        a.execute
        a.session_aliases.size.should eql(0)
      end
      
      it "should display the current list of aliases after adding the new one" do
        a.should_receive(:show_aliases)
        a.execute
      end
    end
    
    context "when removing from the file" do
      before(:each) do
        a = Webbynode::Commands::Alias.new("remove", "my_alias")
        a.should_receive(:io).any_number_of_times.and_return(io)
      end
      
      it "should invoke the remove method" do
        a.should_receive(:send).with('remove')
        a.execute
      end
      
      it "should remove the alias if it exists" do
        a.should_receive(:remove_alias)
        a.execute
      end
      
      it "should remove the specified alias from the array of aliases to write" do
        a.stub!(:read_aliases_file)
        3.times { |n| a.session_aliases << "[alias_#{n}] my_custom_alias_#{n}" }
        a.should have(3).session_aliases
        a.session_aliases << "[my_alias] what a nice alias"
        a.should have(4).session_aliases
        a.session_aliases.should include("[my_alias] what a nice alias")
        a.execute
        a.session_aliases.should_not include("[my_alias] what a nice alias")
        a.should have(3).session_aliases
      end
      
      it "should write to the aliases file to apply the changes" do
        a.should_receive(:write_aliases)
        a.execute
      end
      
      it "should display the current list of aliases after removing the old one" do
        a.should_receive(:show_aliases)
        a.execute
      end
    end
    
    context "reading from the file" do
      before(:each) do
        a = Webbynode::Commands::Alias.new("show")
        a.should_receive(:io).any_number_of_times.and_return(io)
      end
      
      it "should invoke the show method" do
        a.should_receive(:send).with("show")
        a.execute
      end
      
      it "should show the aliases" do
        a.should_receive(:show_aliases)
        a.execute
      end
      
      it "should display all the aliases to the user" do
        a.stub!(:read_aliases_file)
        a.session_aliases << "[my_alias] rake db:migrate"
        io.should_receive(:log).with("These are your current aliases..")
        io.should_receive(:log).with("[my_alias] rake db:migrate")
        a.execute
      end
      
    end
  end
  
end