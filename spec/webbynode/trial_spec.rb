# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Trial do
  describe 'class methods' do
    subject do
      Webbynode::Trial
    end
    
    describe '#add_user' do
      it "creates a new user" do
        FakeWeb.register_uri(:put, "http://trial.webbyapp.com/users", 
          :email => 'fcoury@me.com', :username => 'fcoury', :password => 'secret',
          :response => read_fixture('trial/user_add'))

        response = subject.add_user("fcoury", "secret", "fcoury@me.com")

        response["success"].should be_true
        response["message"].should == 'User fcoury created'
      end
    end
  end
end