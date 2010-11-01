# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Rails do
  let(:io) { double("io").as_null_object }

  subject do
    Webbynode::Engines::Rails.new.tap do |engine|
      engine.stub!(:io).and_return(io)
    end
  end
  
  describe 'class methods' do
    subject { Webbynode::Engines::Rails }

    its(:engine_id)    { should == 'rails' }
    its(:engine_name)  { should == 'Rails 2' }
    its(:git_excluded) { should == ["config/database.yml"] } #, "db/schema.rb"] }
  end
  
  describe '#detect' do
    it "returns true if app app/controllers and config/environent.rb are found" do
      io.stub!(:directory?).with('app').and_return(true)
      io.stub!(:directory?).with('app/controllers').and_return(true)
      io.stub!(:file_exists?).with('config/environent.rb').and_return(true)
      
      subject.should be_detected
    end

    it "returns false if any isn't found" do
      io.stub!(:directory?).with('app').and_return(true)
      io.stub!(:directory?).with('app/controllers').and_return(false)
      io.stub!(:file_exists?).with('config/environent.rb').and_return(true)
      
      subject.should_not be_detected
    end
  end
end
