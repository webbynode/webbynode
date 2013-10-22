# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Rack do
  let(:io) { double("io").as_null_object }

  subject do
    Webbynode::Engines::Rack.new.tap do |engine|
      engine.stub(:io).and_return(io)
    end
  end

  describe 'class methods' do
    subject { Webbynode::Engines::Rack }

    its(:engine_id)    { should == 'rack' }
    its(:engine_name)  { should == 'Rack' }
    its(:git_excluded) { should be_empty }
  end

  describe '#detect' do
    it "if script/rails exists" do
      io.stub(:file_exists?).with('config.ru').and_return(true)

      subject.should be_detected
    end

    it "fails if script/rails doesn't exist" do
      io.stub(:file_exists?).with('config.ru').and_return(false)

      subject.should_not be_detected
    end
  end
end
