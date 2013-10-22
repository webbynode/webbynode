# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Addons do
  let(:io) { double('Io').as_null_object }
  context 'with no params' do
    subject do
      Webbynode::Commands::Addons.new.tap do |cmd|
        cmd.stub(:io).and_return(io)
      end
    end

    it "shows all available addons" do
      io.should_receive(:log).with('Available add-ons:')
      io.should_receive(:log).with('   Key          Name        Description')
      io.should_receive(:log).with('  ------------ ----------- ------------------------')
      io.should_receive(:log).with('   beanstalkd   Beanstalk   Simple, fast workqueue service')
      io.should_receive(:log).with('   memcached    Memcached   Distributed memory object caching system')
      io.should_receive(:log).with('   mongodb      MongoDB     Document based database engine')
      io.should_receive(:log).with('   redis        Redis       Advanced key-value store')
      subject.execute
    end

    it "shows installed addons" do
      io.should_receive(:load_setting).with('addons').and_return(['a', 'b', 'c'])
      io.should_receive(:log).with('Currently selected add-ons:')
      io.should_receive(:log).with('   a, b, c')
      subject.execute
    end

    it "handles malformed addons setting" do
      io.should_receive(:load_setting).with('addons').and_return('somemalformedthing')
      io.should_receive(:log).with("No add-ons currently selected. Use 'wn addons add <name>' to add.")
      subject.execute
    end

    it "doesn't show installed addons if none installed" do
      io.should_receive(:load_setting).with('addons').and_return(nil)
      io.should_receive(:log).with('Currently selected add-ons').never
      io.should_receive(:log).with("No add-ons currently selected. Use 'wn addons add <name>' to add.")
      subject.execute
    end
  end

  context '#remove' do
    context "with no addon parameter" do
      subject do
        Webbynode::Commands::Addons.new('remove').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      it "shows error message" do
        io.should_receive(:log).with("Missing addon to remove. Type 'wn addons' for a list of available addons.")
        subject.execute
      end
    end

    context "with an invalid addon" do
      subject do
        Webbynode::Commands::Addons.new('remove', 'nothing').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      it "shows error message" do
        io.should_receive(:load_setting).with('addons').never
        io.should_receive(:log).with("Addon nothing doesn't exist. Type 'wn addons' for a list of available addons.")
        subject.execute
      end
    end

    context "with an addon not installed" do
      subject do
        Webbynode::Commands::Addons.new('remove', 'redis').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      it "shows error message" do
        io.should_receive(:load_setting).with('addons').and_return(['mongodb'])
        io.should_receive(:log).with("Add-on 'redis' not installed")
        subject.execute
      end
    end

    context "with a valid addon" do
      subject do
        Webbynode::Commands::Addons.new('remove', 'mongodb').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      context "when addon added" do
        it "removes de addon" do
          io.should_receive(:load_setting).with('addons').and_return(['redis', 'mongodb'])
          io.should_receive(:add_multi_setting).with('addons', ['redis'])
          io.should_receive(:log).with("Add-on 'mongodb' removed")
          subject.execute
        end

        it "removes de addon, leaving an empty array" do
          io.should_receive(:load_setting).with('addons').and_return(['mongodb'])
          io.should_receive(:add_multi_setting).with('addons', [])
          io.should_receive(:log).with("Add-on 'mongodb' removed")
          subject.execute
        end
      end
    end
  end

  context '#add' do
    context "with no addon parameter" do
      subject do
        Webbynode::Commands::Addons.new('add').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      it "shows error message" do
        io.should_receive(:log).with("Missing addon to add. Type 'wn addons' for a list of available addons.")
        subject.execute
      end
    end

    context "with an invalid addon" do
      subject do
        Webbynode::Commands::Addons.new('add', 'nothing').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      it "shows error message" do
        io.should_receive(:log).with("Addon nothing doesn't exist. Type 'wn addons' for a list of available addons.")
        subject.execute
      end
    end

    context "with a valid addon" do
      subject do
        Webbynode::Commands::Addons.new('add', 'mongodb').tap do |cmd|
          cmd.stub(:io).and_return(io)
        end
      end

      it "handles malformed addons setting" do
        io.should_receive(:load_setting).with('addons').and_return('somerandomstuff')
        io.should_receive(:add_multi_setting).with('addons', ['mongodb'])
        io.should_receive(:log).with("Add-on 'mongodb' added")
        subject.execute
      end

      context "when setting does not exist" do
        it "create the array" do
          io.should_receive(:load_setting).with('addons').and_return(nil)
          io.should_receive(:add_multi_setting).with('addons', ['mongodb'])
          io.should_receive(:log).with("Add-on 'mongodb' added")
          subject.execute
        end
      end

      context "when setting exists" do
        it "add the engine to the array" do
          io.should_receive(:load_setting).with('addons').and_return(['redis'])
          io.should_receive(:add_multi_setting).with('addons', ['redis', 'mongodb'])
          subject.execute
        end
      end

      context "when addon already added" do
        it "keep the array as is" do
          io.should_receive(:load_setting).with('addons').and_return(['mongodb'])
          io.should_receive(:add_multi_setting).never
          io.should_receive(:log).with("Add-on 'mongodb' added").never
          io.should_receive(:log).with("Add-on 'mongodb' was already included")
          subject.execute
        end
      end
    end
  end
end
