# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::NodeJS do
  describe 'class methods' do
    subject { Webbynode::Engines::NodeJS }

    its(:engine_id)    { should == 'nodejs' }
    its(:engine_name)  { should == 'NodeJS' }
    its(:git_excluded) { should be_empty }
  end
end