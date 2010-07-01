# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Django do
  describe 'class methods' do
    subject { Webbynode::Engines::Django }

    its(:engine_id)    { should == 'django' }
    its(:engine_name)  { should == 'Django' }
    its(:git_excluded) { should be_empty }
  end
end