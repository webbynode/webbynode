# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Webbynode do
  describe Webbynode::ApiClient do
    describe "webby_ip" do
      describe "when file ~/.webbynode is absent" do
        it "should call init_credentials email address and API token" do
          FakeWeb.register_uri(:post, "#{Webbynode::Application.base_uri}/webbies", 
            :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

          wn = Webbynode::Application.new("")
          wn.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
          wn.webby_ip("webby3067").should == "61.21.71.31"

          wn = Webbynode::Application.new("")
          wn.should_receive(:init_credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
          wn.webby_ip("sandbox").should == "201.81.121.201"
        end
      end

      describe "when file ~/.webbynode is present" do
        before do
          FakeWeb.clean_registry
          FakeWeb.register_uri(:post, "#{Webbynode::Application.base_uri}/webbies", 
            :email => "fcoury@me.com", :response => read_fixture("api/webbies"))
        end

        it "should return the IP for existing Webby hostname" do
          wn = Webbynode::Application.new("")
          wn.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
          wn.webby_ip("sandbox").should == "201.81.121.201"
        end

        it "should show an error message if the Webby does not exist for the user" do
          wn = Webbynode::Application.new("")
          wn.should_receive(:credentials).and_return({:email => "fcoury@me.com", :token => "apitoken"})
          wn.webby_ip("this_doesnt_exist").nil?.should == true
        end
      end
    end

    describe "init_credentials" do
      it "should ask the user for credentials when ~/.webbynode is missing" do
        File.should_receive(:exists?).twice.with("#{ENV['HOME']}/.webbynode").and_return(false)

        wn = Webbynode::Application.new("")
        wn.should_receive(:ask).with("API Token:   ").and_return("apitoken")
        wn.should_receive(:ask).with("Login email: ").and_return("fcoury@me.com")
        wn.should_receive(:create_yaml_file)
        wn.init_credentials.should == {:email => "fcoury@me.com", :token => "apitoken"}

        wn = Webbynode::Application.new("")
        wn.should_receive(:ask).with("API Token:   ").and_return("anothertoken")
        wn.should_receive(:ask).with("Login email: ").and_return("you@mail.com")
        wn.should_receive(:create_yaml_file)
        wn.init_credentials.should == {:email => "you@mail.com", :token => "anothertoken"}
      end

      it "should read ~/.webbynode if present" do
        yaml_file_contents = read_fixture("api/credentials")

        File.should_receive(:exists?).with("#{ENV['HOME']}/.webbynode").and_return(true)
        File.should_receive(:read).with("#{ENV['HOME']}/.webbynode").and_return(yaml_file_contents)

        wn = Webbynode::Application.new("")
        wn.init_credentials.should == {:email => "fcoury@me.com", :token => "apitoken"}
      end

      it "should save the credentials in ~/.webbynode" do
        wn = Webbynode::Application.new("")
        File.should_receive(:exists?).with("#{ENV['HOME']}/.webbynode").and_return(false)

        wn.should_receive(:ask).with("API Token:   ").and_return("apitoken")
        wn.should_receive(:ask).with("Login email: ").and_return("fcoury@me.com")
        wn.should_receive(:create_yaml_file).with("#{ENV['HOME']}/.webbynode", {:email => "fcoury@me.com", :token => "apitoken"})
        wn.init_credentials.should == {:email => "fcoury@me.com", :token => "apitoken"}
      end
    end
  end
end