# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Rails3 do
  let(:io) { double("io").as_null_object }

  subject do
    Webbynode::Engines::Rails3.new.tap do |engine|
      engine.stub!(:io).and_return(io)
    end
  end
  
  describe '#detect' do
    it "if script/rails exists" do
      io.stub!(:file_exists?).with('script/rails').and_return(true)
      
      subject.should be_detected
    end

    it "fails if script/rails doesn't exist" do
      io.stub!(:file_exists?).with('script/rails').and_return(false)
      
      subject.should_not be_detected
    end
  end
end
