# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Accounts do
  let(:api) { double("API") }
  let(:io)  { double("Io").as_null_object }
  
  def prepare(*params)
    Webbynode::Commands::Accounts.new(*params).tap do |a|
      a.stub(:api).and_return(api)
      a.stub(:io).and_return(io)
    end
  end
  
  describe '#list' do
    let(:dir) { Webbynode::Io.home_dir }
    subject { prepare "list" }

    it "shows all available accounts" do
      api.stub(:credentials => {"email" => "fcoury@me.com", "token" => "apitoken", "system" => "manager"})
      io.stub(:list_files).with("#{dir}/.webbynode_*").and_return(["#{dir}/.webbynode_personal", "#{dir}/.webbynode_biz", "#{dir}/.webbynode_other"])
      io.stub(:file_matches).with("#{dir}/.webbynode_personal", /email=fcoury@me.com/).and_return(true)
      io.stub(:file_matches).with("#{dir}/.webbynode_personal", /system=manager$/).and_return(true)
      io.stub(:file_matches).with("#{dir}/.webbynode_other", /email=fcoury@me.com/).and_return(true)
      io.stub(:file_matches).with("#{dir}/.webbynode_other", /system=manager$/).and_return(false)
      io.stub(:file_matches).with("#{dir}/.webbynode_biz", /email=fcoury@me.com/).and_return(false)
      io.stub(:file_matches).with("#{dir}/.webbynode_biz", /system=manager$/).and_return(false)

      io.should_receive(:log).with("* personal")
      io.should_receive(:log).with("  biz")
      io.should_receive(:log).with("  other")
      subject.execute
    end
    
    it "tells when no configs found" do
      io.should_receive(:list_files).with("#{Webbynode::Io.home_dir}/.webbynode_*").and_return([])
      io.should_receive(:log).with("No accounts found. Use 'wn accounts save' to save current account with an alias.")
      subject.execute
    end
  end
  
  describe '#save' do
    subject { prepare "save", "name" }
    
    it "copies the properties file" do
      io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(false)
      io.should_receive(:copy_file).with("#{Webbynode::Io.home_dir}/.webbynode", "#{Webbynode::Io.home_dir}/.webbynode_name")
      subject.execute
    end
    
    context "file exists" do
      context "when confirms overwriting" do
        it "overwrites the file" do
          io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(true)
          subject.should_receive(:ask).with("Do you want to overwrite saved account name (y/n)? ").once.ordered.and_return("y")
          io.should_receive(:copy_file).with("#{Webbynode::Io.home_dir}/.webbynode", "#{Webbynode::Io.home_dir}/.webbynode_name")

          subject.execute
        end
      end

      context "when aborts overwriting" do
        it "doesn't overwrite the file" do
          io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(true)
          subject.should_receive(:ask).with("Do you want to overwrite saved account name (y/n)? ").once.ordered.and_return("n")
          io.should_receive(:copy_file).with("#{Webbynode::Io.home_dir}/.webbynode", "#{Webbynode::Io.home_dir}/.webbynode_name").never
          io.should_receive(:log).with("Save aborted.")

          subject.execute
        end
      end
    end
  end
  
  describe '#use' do
    subject { prepare "use", "name" }
    
    it "renames the properties file" do
      io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(true)
      io.should_receive(:copy_file).with("#{Webbynode::Io.home_dir}/.webbynode_name", "#{Webbynode::Io.home_dir}/.webbynode")
      io.should_receive(:log).with("Successfully switched to account alias name.")
      subject.execute
    end
    
    context "when file doesn't exist" do
      it "shows an error message" do
        io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(false)
        io.should_receive(:log).with("Account alias name not found. Use wn account list for a full list.")
        subject.execute
      end
    end
  end
  
  describe '#new' do
    subject { prepare "new" }
    
    it "reinitializes the account" do
      api.should_receive(:init_credentials).with(true)
      subject.execute
    end
  end
  
  describe '#delete' do
    subject { prepare "delete", "name" }
    
    it "deletes the account" do
      io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(true)
      io.should_receive(:delete_file).with("#{Webbynode::Io.home_dir}/.webbynode_name")
      subject.execute
    end
    
    context "when account doesn't exist" do
      it "shows an error" do
        io.should_receive(:file_exists?).with("#{Webbynode::Io.home_dir}/.webbynode_name").and_return(false)
        io.should_receive(:log).with("Account alias name not found. Use wn account list for a full list.")
        subject.execute
      end
    end
  end
  
  describe '#rename' do
    let(:dir) { Webbynode::Io.home_dir }
    subject { prepare "rename", "old_name", "new_name" }
    
    it "renames the .webbynode_xxx file" do
      io.should_receive(:file_exists?).with("#{dir}/.webbynode_old_name").and_return(true)
      io.should_receive(:file_exists?).with("#{dir}/.webbynode_new_name").and_return(false)
      io.should_receive(:rename_file).with("#{dir}/.webbynode_old_name", "#{dir}/.webbynode_new_name")
      io.should_receive(:log).with("Account alias old_name successfully renamed to new_name.")
      subject.execute
    end
    
    it "raises an error if file doesn't exist" do
      io.should_receive(:file_exists?).with("#{dir}/.webbynode_old_name").and_return(false)
      io.should_receive(:rename_file).never
      io.should_receive(:log).with(/not found/)
      subject.execute
    end
    
    it "raises an error if target file already exist" do
      io.should_receive(:file_exists?).with("#{dir}/.webbynode_old_name").and_return(true)
      io.should_receive(:file_exists?).with("#{dir}/.webbynode_new_name").and_return(true)
      io.should_receive(:rename_file).never
      io.should_receive(:log).with("Account alias new_name already exists, use wn account delete to remove it first.")
      subject.execute
    end
  end
end
