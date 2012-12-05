# Load Spec Helper
# require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

# describe Webbynode::Commands::User do
#   context 'add action' do
#     let(:io) { double('Io').as_null_object }
    
#     subject do
#       Webbynode::Commands::User.new('add').tap do |cmd|
#         cmd.stub!(:io).and_return(io)
#       end
#     end
    
#     it "creates the user" do
#       io.should_receive(:general_settings).and_return({})
#       io.should_receive(:add_general_setting).with('rapp_username', 'fcoury')
      
#       FakeWeb.register_uri(:put, "http://trial.webbyapp.com/users", 
#         :email => 'fcoury@me.com', :username => 'fcoury', :password => 'secret',
#         :response => read_fixture('trial/user_add'))
      
#       subject.should_receive(:ask).with('Email: ').and_return('fcoury@me.com')
#       subject.should_receive(:ask).with('         Username: ').and_return('fcoury')
#       subject.should_receive(:ask).with('Choose a password: ').and_return('secret')
#       subject.should_receive(:ask).with('   Enter it again: ').and_return('secret')
#       subject.run
#     end
    
#     it "checks for existing user first" do
#       io.should_receive(:general_settings).and_return({ 'rapp_username' => 'fcoury' })
#       io.should_receive(:log).with('User fcoury is already configured for Rapp Trial.')
#       io.should_receive(:log).with('Aborted.')
#       subject.should_receive(:ask).with('Do you want to overwrite this settings (y/n)?').and_return('n')
#       subject.run
#     end
#   end
# end