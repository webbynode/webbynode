# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode::Server do
  describe "add_ssh_key" do
    context "when unsuccessful" do
      it "should create a local SSH key if one is not found" do
        io = mock("io")
        io.should_receive(:file_exists?).with("xyz").and_return(false)
        io.should_receive(:create_local_key).with("xyz", nil)
      
        server = Webbynode::Server.new
        server.should_receive(:io).any_number_of_times.and_return(io)
        server.add_key "xyz"
      end

      it "should create a local SSH key with the provided passphrase if one is not found" do
        io = mock("io")
        io.should_receive(:file_exists?).with("abc").and_return(false)
        io.should_receive(:create_local_key).with("abc", "my_passphrase")
      
        server = Webbynode::Server.new
        server.should_receive(:io).any_number_of_times.and_return(io)
        server.add_key "abc", "my_passphrase"
      end
    end
    
    context "when unsuccessful" do
      it "should raise a PermissionError if cannot write the key" do
        io = mock("io")
        io.should_receive(:file_exists?).with("xyz").and_return(false)
        io.should_receive(:create_local_key).and_raise(Webbynode::PermissionError)
      
        server = Webbynode::Server.new
        server.should_receive(:io).any_number_of_times.and_return(io)
        lambda { server.add_key "xyz" }.should raise_exception(Webbynode::PermissionError)
      end
    end
  end
end
