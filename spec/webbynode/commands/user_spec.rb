# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::User do
  context 'add action' do
    subject do
      Webbynode::Commands::User.new('add').tap do |cmd|
      end
    end
    
    it "creates the user" do
      FakeWeb.register_uri(:put, "http://trial.webbyapp.com/users", 
        :email => 'fcoury@me.com', :username => 'fcoury', :password => 'secret',
        :response => read_fixture('trial/user_add'))
      
      subject.should_receive(:ask).with('Email: ').and_return('fcoury@me.com')
      subject.should_receive(:ask).with('Username: ').and_return('fcoury')
      subject.should_receive(:ask).with('Password: ').and_return('secret')
      subject.run
    end
  end
end