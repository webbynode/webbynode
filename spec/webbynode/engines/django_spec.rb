# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Engines::Django do
  describe 'class methods' do
    subject { Webbynode::Engines::Django }

    its(:engine_id)    { should == 'django' }
    its(:engine_name)  { should == 'Django' }
    its(:git_excluded) { should == ['settings.py', '*.pyc', '*.pyo', 'docs/_build'] }
  end

  let(:io) { double('Io') }
  before(:each) { subject.stub(:io).and_return(io) }

  describe '#change_settings' do
    it "calls sed to change" do
      io.should_receive(:sed).with('settings.template.py', /'ENGINE': '[^ ,]*'/, "'ENGINE': 'engine'")
      io.should_receive(:sed).with('settings.template.py', /'NAME': '[^ ,]*'/, "'NAME': 'name'")
      subject.change_settings({
        'NAME' => 'name',
        'ENGINE' => 'engine'
      })
    end
  end

  describe '#change_templates' do
    it "calls sed to change" do
      io.should_receive(:sed).with('settings.template.py', /TEMPLATE_DIRS = \(/, "TEMPLATE_DIRS = (\n    '@app_dir@/templates'")
      subject.change_templates
    end
  end

  describe '#prepare' do
    context 'when settings.py is missing' do
      it "raises an error" do
        io.should_receive(:file_exists?).with('settings.py').and_return(false)
        io.should_receive(:file_exists?).with('settings.template.py').never
        io.should_receive(:copy_file).never

        lambda { subject.prepare }.should raise_error(Webbynode::Command::CommandError, "Couldn't create the settings template because settings.py was not found. Please check and try again.")
      end
    end

    context "when settings.template.py doesn't exist" do
      it "creates settings.template.py based on settings.py" do
        io.should_receive(:file_exists?).with('settings.py').and_return(true)
        io.should_receive(:file_exists?).with('settings.template.py').and_return(false)
        io.should_receive(:copy_file).with('settings.py', 'settings.template.py')
        io.should_receive(:log).with('Creating settings.template.py from your settings.py...')

        subject.should_receive(:change_templates)
        subject.should_receive(:change_settings).with({
          'ENGINE' => '@app_engine@',
          'NAME' => '@app_name@',
          'USER' => '@app_name@',
          'PASSWORD' => '@app_pwd@',
          'HOST' => '@db_host@',
          'PORT' => '@db_port@',
        })
        subject.prepare
      end
    end

    context "when settings.template.py exists" do
      it "doesn't do anything" do
        io.should_receive(:log).never
        io.should_receive(:file_exists?).with('settings.py').and_return(true)
        io.should_receive(:file_exists?).with('settings.template.py').and_return(true)
        io.should_receive(:copy_file).never
        subject.should_receive(:change_settings).never
        subject.should_receive(:change_templates).never
        subject.prepare
      end
    end
  end
end
