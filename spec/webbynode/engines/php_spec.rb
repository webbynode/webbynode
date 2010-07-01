# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Php do
  describe 'class methods' do
    subject { Webbynode::Engines::Php }

    its(:engine_id)    { should == 'php' }
    its(:engine_name)  { should == 'PHP' }
    its(:git_excluded) { should be_empty }
  end
end