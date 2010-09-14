# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::WSGI do
  let(:io) { double("io").as_null_object }

  subject do
    Webbynode::Engines::WSGI.new.tap do |engine|
      engine.stub!(:io).and_return(io)
    end
  end
  
  describe 'class methods' do
    subject { Webbynode::Engines::WSGI }

    its(:engine_id)    { should == 'wsgi' }
    its(:engine_name)  { should == 'WSGI' }
    its(:git_excluded) { should be_empty }
  end
end
