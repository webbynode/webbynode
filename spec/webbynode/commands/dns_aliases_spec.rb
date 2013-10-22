# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::DnsAliases do
  let(:pushand) { double("pushand").as_null_object }
  let(:re)      { double("RemoteExecutor").as_null_object }
  let(:io)      { double("Io").as_null_object }

  def prepare(*params)
    Webbynode::Commands::DnsAliases.new(*params).tap do |a|
      a.stub(:remote_executor).and_return(re)
      a.stub(:pushand).and_return(pushand)
      a.stub(:io).and_return(io)
    end
  end

  describe '#show' do
    subject { prepare "show" }

    it "shows all current aliases" do
      io.should_receive(:load_setting).with('dns_alias').and_return("'alias1.com'")
      io.should_receive(:log).with('Current aliases: alias1.com')

      subject.execute
    end

    it "tells the user that there are no current aliases" do
      io.should_receive(:load_setting).with('dns_alias').and_return(nil)
      io.should_receive(:log).with("No current aliases. To add new aliases use:\n\n  #{File.basename $0} dns_aliases add new-dns-alias")

      subject.execute
    end
  end

  describe '#add' do
    subject { prepare 'add', 'alias2.com' }

    it "adds a new alias" do
      io.should_receive(:load_setting).with('dns_alias').and_return("'alias1.com'")
      io.should_receive(:add_setting).with('dns_alias', "'alias1.com alias2.com'")
      io.should_receive(:log).with('Alias alias2.com added.')
      io.should_receive(:log).with('Current aliases: alias1.com alias2.com')

      subject.execute
    end

    it "properly spaces existing aliases" do
      io.should_receive(:load_setting).with('dns_alias').and_return("'alias0.com alias1.com'")
      io.should_receive(:add_setting).with('dns_alias', "'alias0.com alias1.com alias2.com'")

      subject.execute
    end

    it "tells when alias already exist" do
      io.should_receive(:load_setting).with('dns_alias').and_return("'alias2.com'")
      io.should_receive(:log).with("Alias alias2.com already exists.")
      io.should_receive(:add_setting).never

      subject.execute
    end
  end

  describe '#remove' do
    subject { prepare 'remove', 'alias2.com' }

    it "removes the alias from the list" do
      io.should_receive(:load_setting).with('dns_alias').and_return("'alias1.com alias2.com other.co.uk'")
      io.should_receive(:add_setting).with('dns_alias', "'alias1.com other.co.uk'")
      io.should_receive(:log).with('Alias alias2.com removed.')
      io.should_receive(:log).with('Current aliases: alias1.com other.co.uk')

      subject.execute
    end

    it "tells when alias doesn't exist" do
      io.should_receive(:load_setting).with('dns_alias').and_return("'alias1.com'")
      io.should_receive(:log).with("Alias alias2.com doesn't exist.")
      io.should_receive(:add_setting).never

      subject.execute
    end

    it "works with and without quotes" do
      io.should_receive(:load_setting).with('dns_alias').and_return("alias2.com")
      io.should_receive(:add_setting).with('dns_alias', "''")

      subject.execute
    end
  end
end
