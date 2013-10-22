# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Gemfile do
  let(:io)      { double("dummy_io_handler").as_null_object }

  subject {
    Webbynode::Gemfile.new.tap do |gemfile|
      gemfile.stub(:io).and_return(io)
    end
  }

  describe "#present?" do
    it "is true when Gemfile exists" do
      io.should_receive(:file_exists?).with("Gemfile").and_return(true)
      subject.should be_present
    end

    it "is false when Gemfile doesn't exist" do
      io.should_receive(:file_exists?).with("Gemfile").and_return(false)
      subject.should_not be_present
    end
  end

  describe "#dependencies" do
    it "filters out groups if present" do
      dep1 = double("dep1")
      dep1.stub(:name).and_return('dep1')
      dep1.stub(:groups).and_return([:default])

      dep2 = double("dep2")
      dep2.stub(:name).and_return('dep2')
      dep2.stub(:groups).and_return([:development])

      dep3 = double("dep3")
      dep3.stub(:name).and_return('dep3')
      dep3.stub(:groups).and_return([:test])

      dep3 = double("dep4")
      dep3.stub(:name).and_return('dep4')
      dep3.stub(:groups).and_return([:default, :test])

      definitions  = double("definitions")
      dependencies = [dep1, dep2, dep3]

      Bundler.should_receive(:definition).and_return(definitions)
      definitions.should_receive(:dependencies).and_return(dependencies)

      subject.dependencies(:without => ['development', 'test']).should == ['dep1']
    end
  end
end
