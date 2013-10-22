# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Settings do
  let(:io)      { double("Io").as_null_object }

  context 'with no params' do
    subject do
      Webbynode::Commands::Settings.new.tap do |cmd|
        cmd.stub(:io).and_return(io)
      end
    end

    it "lists all current settings" do
      io.should_receive(:with_setting).and_yield({ 'setting1' => 'value1', 'setting2' => 'value2' })
      io.should_receive(:log).with('setting1 = value1')
      io.should_receive(:log).with('setting2 = value2')
      subject.execute
    end
  end

  context 'adding' do
    it "adds a new setting" do
      cmd = Webbynode::Commands::Settings.new("add", "hello", "world").tap do |cmd|
        cmd.stub(:io).and_return(io)
      end

      io.should_receive(:add_setting).with('hello', 'world')

      cmd.execute
    end
  end

  context 'removing' do
    it "removes an existing setting" do
      cmd = Webbynode::Commands::Settings.new("remove", "hello").tap do |cmd|
        cmd.stub(:io).and_return(io)
      end

      io.should_receive(:remove_setting).with('hello')

      cmd.execute
    end
  end
end
