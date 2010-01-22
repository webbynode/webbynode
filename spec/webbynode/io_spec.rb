# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Io do
  describe "#app_name" do
    context "when successful" do
      it "should return the current folder" do
        Dir.should_receive(:pwd).and_return("/some/deep/folder/where/you/find/app_name")
        Webbynode::Io.new.app_name.should == "app_name"
      end

      it "should transform dots and spaces into underscores" do
        Dir.should_receive(:pwd).and_return("/some/deep/folder/where/you/find/my.app here")
        Webbynode::Io.new.app_name.should == "my_app_here"
      end
    end
  end
  
  describe '#create_local_key' do
    describe "when key file missing" do
      before(:each) do
        File.should_receive(:exists?).with(Webbynode::Commands::AddKey::LocalSshKey).and_return(false)
        @io = Webbynode::Io.new
      end

      context "with no passphrase" do
        it "should create the key with an empty passphrase" do
          @io.should_receive(:exec).with("ssh-keygen -t rsa -N \"\" -f #{Webbynode::Commands::AddKey::LocalSshKey}").and_return("")
          @io.create_local_key
        end
      end
      
      context "with a passphrase" do
        it "should create the key with the provided passphrase" do
          @io.should_receive(:exec).with("ssh-keygen -t rsa -N \"passphrase\" -f #{Webbynode::Commands::AddKey::LocalSshKey}").and_return("")
          @io.create_local_key("passphrase")
        end
      end
    end
    
    describe '#templates_path' do
      it "should return the contents of TemplatesPath" do
        io = Webbynode::Io.new
        io.templates_path.should == Webbynode::Io::TemplatesPath
      end
    end
    
    describe '#create_from_template' do
      it "should read the template and write a new file with its contents" do
        io = Webbynode::Io.new
        io.should_receive(:read_from_template).with("template_file").and_return("template_file_contents")
        io.should_receive(:create_file).with("template_file", "template_file_contents")
        io.create_from_template("template_file")
      end
    end
    
    describe '#read_from_template' do
      it "should read a file from the templates path" do
        io = Webbynode::Io.new
        io.should_receive(:templates_path).and_return("/templates")
        io.should_receive(:read_file).with("/templates/template_file").and_return("template_contents")
        io.read_from_template("template_file").should == "template_contents"
      end
    end
    
    describe '#create_file' do
      it "should create a file with specified contents" do
        file = double("File")
        File.should_receive(:open).with("file_to_write", "w").and_yield(file)
        file.should_receive(:write).with("file_contents")

        io = Webbynode::Io.new
        io.create_file("file_to_write", "file_contents")
      end
    end
    
    describe "when key already exists" do
      before(:each) do
        File.should_receive(:exists?).with(Webbynode::Commands::AddKey::LocalSshKey).and_return(true)
        @io = Webbynode::Io.new
      end
      
      it "should just skip the creation" do
        @io.should_receive(:exec).never
        @io.create_local_key
      end
    end
  end
  
  describe "#exec" do
    context "when successful" do
      it "should execute the command and retrieve the output" do
        io = Webbynode::Io.new
        io.should_receive(:`).with("ls -la").and_return("output for ls -la")
        io.exec("ls -la").should == "output for ls -la"
      end
    end
  end
  
  describe "#read_file" do
    context "when successful" do
      it "should return file contents" do
        io = Webbynode::Io.new
        File.should_receive(:read).with("filename").and_return("file contents")
        io.read_file("filename").should == "file contents"
      end
    end
  end
  
  describe "#directory?" do
    context "when successful" do
      it "should return true when item is a directory" do
        File.should_receive(:directory?).with("dir").and_return(true)

        io = Webbynode::Io.new
        io.directory?("dir").should == true
      end

      it "should return false when item is not a directory" do
        File.should_receive(:directory?).with("dir").and_return(false)

        io = Webbynode::Io.new
        io.directory?("dir").should == false
      end
    end
  end
  
  describe "#open_file" do
    it "should open the file" do
      io = Webbynode::Io.new
      File.should_receive(:open).with("filename").and_return("file contents")
      io.open_file("filename").should eql("file contents")
    end
  end
end