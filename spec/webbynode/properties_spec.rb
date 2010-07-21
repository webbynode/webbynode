# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Properties do
  describe '#initialize' do
    it "handles multi params" do
      IO.should_receive(:foreach).with('file').and_yield("a=b").and_yield("c=d").and_yield("e=(f g htg1)")
      $testing = false
      p = Webbynode::Properties.new('file')
      $testing = true
      p['a'].should == 'b'
      p['c'].should == 'd'
      p['e'].should == ['f', 'g', 'htg1']
    end
  end
end