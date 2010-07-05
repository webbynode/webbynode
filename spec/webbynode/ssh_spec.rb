# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Ssh do
  context 'with no port' do
    subject { Webbynode::Ssh.new("2.2.1.1") }
    
    describe '#port' do
      its(:port) { should == 22 }
    end

    describe '#connect' do
      it 'calls start passing port 22' do
        Net::SSH.should_receive(:start).with("2.2.1.1", 'git', hash_including(:port => 22))
        subject.connect
      end
    end
  end
  
  context 'with no port' do
    subject { Webbynode::Ssh.new("2.2.12.12", 2020) }
    
    describe '#port' do
      its(:port) { should == 2020 }
    end

    describe '#connect' do
      it 'calls start passing specified port' do
        Net::SSH.should_receive(:start).with("2.2.12.12", 'git', hash_including(:port => 2020))
        subject.connect
      end
    end
  end
end