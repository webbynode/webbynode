# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::NodeJS do
  let(:io) { double("io").as_null_object }

  subject do
    Webbynode::Engines::NodeJS.new.tap do |engine|
      engine.stub!(:io).and_return(io)
    end
  end

  describe 'class methods' do
    subject { Webbynode::Engines::NodeJS }

    its(:engine_id)    { should == 'nodejs' }
    its(:engine_name)  { should == 'NodeJS' }
    its(:git_excluded) { should be_empty }
  end

  describe '#detect' do
    before do
      io.stub(:file_exists?)
    end

    it "returns true if server.js is found" do
      io.stub!(:file_exists?).with('server.js').and_return(true)
      
      subject.should be_detected
    end

    it "returns true if app.js is found" do
      io.stub!(:file_exists?).with('app.js').and_return(true)
      
      subject.should be_detected
    end

    it "returns false if both app.js and server.js aren't found" do
      io.stub!(:file_exists?).with('server.js').and_return(false)
      io.stub!(:file_exists?).with('app.js').and_return(false)
      
      subject.should_not be_detected
    end
  end
  
  describe '#prepare' do
    before(:each) do
      io.stub(:file_exists? => false)
    end
    
    it "tries to get the listen port" do
      io.stub!(:file_exists?).with('server.js').and_return(true)
      io.should_receive(:read_file).with("server.js").and_return(read_fixture("nodejs/server.js"))
      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('Y')
      subject.should_receive(:ask).with("     Listening port [1234]: ").and_return('')

      io.should_receive(:add_setting).with('nodejs_port', '1234')

      subject.prepare
    end
    
    it "shows a title" do
      io.should_receive(:log).with("Configure NodeJS Application")
      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('Y')
      subject.should_receive(:ask).with("     Listening port [8000]: ").and_return(8080)
      subject.prepare
    end
    
    it "validates y/n for proxy" do
      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('abcdef')
      io.should_receive(:log).with("  Please answer Y=use proxy or N=don't use proxy (standalone NodeJS app)")
      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('N')
      subject.should_receive(:ask).with("     Listening port [8000]: ").and_return(8080)
      subject.prepare
    end
    
    it "validates numeric for port" do
      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('N')
      subject.should_receive(:ask).with("     Listening port [8000]: ").and_return('abcdef')
      io.should_receive(:log).with("  Please enter a numeric value for port")
      subject.should_receive(:ask).with("     Listening port [8000]: ").and_return("8080")
      subject.prepare
    end
    
    it "asks if user wants to proxy requests and the port" do
      io.should_receive(:add_setting).with('nodejs_proxy', 'Y')
      io.should_receive(:add_setting).with('nodejs_port', '8080')

      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('Y')
      subject.should_receive(:ask).with("     Listening port [8000]: ").and_return(8080)
      subject.prepare
    end
    
    it "assumes default values" do
      io.should_receive(:add_setting).with('nodejs_proxy', 'Y')
      io.should_receive(:add_setting).with('nodejs_port', '8000')

      subject.should_receive(:ask).with("  Proxy requests (Y/n) [Y]? ").and_return('')
      subject.should_receive(:ask).with("     Listening port [8000]: ").and_return('')
      subject.prepare
    end
  end
end