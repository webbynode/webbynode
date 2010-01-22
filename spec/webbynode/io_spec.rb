# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Io do
  describe "app_name" do
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
  
  describe "exec" do
    context "when successful" do
      it "should execute the command and retrieve the output" do
        io = Webbynode::Io.new
        io.should_receive(:`).with("ls -la").and_return("output for ls -la")
        io.exec("ls -la").should == "output for ls -la"
      end
    end
  end
  
  describe "read_file" do
    context "when successful" do
      it "should return file contents" do
        io = Webbynode::Io.new
        File.should_receive(:read).with("filename").and_return("file contents")
        io.read_file("filename").should == "file contents"
      end
    end
  end
  
  describe "directory?" do
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
end