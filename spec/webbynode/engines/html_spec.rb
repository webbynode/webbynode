# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Html do
  describe 'class methods' do
    subject { Webbynode::Engines::Html }

    its(:engine_id)    { should == 'html' }
    its(:engine_name)  { should == 'Html' }
    its(:git_excluded) { should be_empty }
  end
end