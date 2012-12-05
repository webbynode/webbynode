# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Init do
  let(:git_handler) { double("git").as_null_object }
  let(:io_handler)  { double("io").as_null_object }
  let(:gemfile)     { double("gemfile").as_null_object.tap { |g| g.stub!(:present?).and_return(false) } }
  let(:api)         { double("api").as_null_object }
  let(:pushand)     { stub.as_null_object }
  let(:instance)    { stub(:instance).as_null_object }
  
  def create_init(ip="4.3.2.1", host=nil, extra=[])
    host = "--dns=#{host}" if host
    @command = Webbynode::Commands::Init.new(ip, host, *extra)
    @command.stub!(:gemfile).and_return(gemfile)
    @command.should_receive(:git).any_number_of_times.and_return(git_handler) 
    @command.should_receive(:io).any_number_of_times.and_return(io_handler)
    @command.stub!(:pushand).and_return(pushand)
    io_handler.stub!(:file_exists?).with(".pushand").and_return(false)
  end
  
  before(:each) do
    server = stub('Server').as_null_object
    Webbynode::Server.stub!(:new).and_return(server)
    FakeWeb.clean_registry
    create_init
    git_handler.stub!(:remote_exists?).and_return(false)
    Webbynode::ApiClient.stub(:system => "manager")
    Webbynode::ApiClient.stub(:instance => instance)
  end

  def make_webby(hash)
    webby        = Webbynode::Webby.new
    hash.each_pair { |k,v| webby.send("#{k}=", v) }
    webby
  end
  
  subject do
    Webbynode::Commands::Init.new.tap do |cmd|
      webby        = Webbynode::Webby.new
      webby.ip     = "201.81.121.201"
      webby.status = "on"
      webby.name   = "sandbox"
      webby.plan   = "Webbybeta"
      webby.node   = "miami-b15"

      webbies = { 'sandbox' => webby }

      api.stub!(:webbies).and_return(webbies)

      cmd.stub!(:git).and_return(git_handler)
      cmd.stub!(:io).and_return(io_handler)
      cmd.stub!(:api).and_return(api)
      cmd.stub!(:pushand).and_return(pushand)
    end      
  end
  
  describe '#create_pushand' do
    it "creates .pushand when missing" do
      subject.should_receive(:pushand_exists?).and_return(false)
      pushand.should_receive(:create!)
      subject.create_pushand
    end
  end
  
  describe 'in trial mode' do
    subject do 
      Webbynode::Commands::Init.new('--trial').tap do |cmd|
        cmd.stub!(:git).and_return(git_handler)
        cmd.stub!(:io).and_return(io_handler)
        cmd.stub!(:api).and_return(api)
      end
    end
    
    before(:each) do
      subject.stub(:check_git_clean)
      subject.stub(:detect_engine)
    end

    it "uses rapp_username when found" do
      io_handler.should_receive(:general_settings).and_return({ 'rapp_username' => 'user' })
      io_handler.should_receive(:app_name).and_return('trial_app')
      git_handler.should_receive(:add_remote).with('user', 'webbynode', 'trial.webbyapp.com', 'trial_app', :home => '/home/user')

      subject.should_receive(:get_ip).never
      subject.should_receive(:create_pushand)
      subject.run
    end
    
    it "asks for trial username when not found" do
      io_handler.should_receive(:general_settings).and_return({})
      io_handler.should_receive(:app_name).and_return('trial_app')
      subject.should_receive(:ask).with('Enter your Rapp trial user: ').and_return('user')
      io_handler.should_receive(:add_general_setting).with('rapp_username', 'user')
      git_handler.should_receive(:add_remote).with('user', 'webbynode', 'trial.webbyapp.com', 'trial_app', :home => '/home/user')

      subject.should_receive(:get_ip).never
      subject.should_receive(:create_pushand)
      subject.run
    end
  end
  
  describe 'when the SSH known_hosts key differs' do
    it "gives an user friendly explanation" do
      io_handler.stub!(:file_exists?).with(".pushand").and_return(false)

      git_handler.stub!(:present?).and_return(:false)

      subject.stub!(:git).and_return(git_handler)
      subject.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)

      subject.should_receive(:add_remote).and_raise(Net::SSH::HostKeyMismatch.new("fingerprint 91:b5:b6:08:91:61:f7:d7:66:ec:c0:a9:53:16:c6:84 does not match for \"208.88.124.171\""))
      
      io_handler.should_receive(:log).with("Error pushing to your server:")
      io_handler.should_receive(:log).with("  fingerprint 91:b5:b6:08:91:61:f7:d7:66:ec:c0:a9:53:16:c6:84 does not match for \"208.88.124.171\"")
      io_handler.should_receive(:log).with("This usually happens because you redeployed the server and the fingerprint changed.")
      io_handler.should_receive(:log).with("To fix this error:")
      io_handler.should_receive(:log).with("  1. Edit #{Webbynode::Io.home_dir}/.ssh/known_hosts file")
      io_handler.should_receive(:log).with("     or the proper known hosts file for your SSH service.")
      io_handler.should_receive(:log).with("  2. Remove the line that starts with the IP 201.81.121.201.")
      
      subject.run
    end
  end
  
  describe 'using alternate port' do
    subject do 
      Webbynode::Commands::Init.new('2.1.2.3', '--port=2020').tap do |cmd|
        cmd.stub!(:git_present).and_return(:false)
        cmd.stub!(:io).and_return(io_handler)
      end
    end
    
    it "calls add_remote with the specified port" do
      io_handler.stub!(:file_exists?).with(".pushand").and_return(false)

      git_handler.stub!(:present?).and_return(:false)
      git_handler.should_receive(:add_remote).with("git", "webbynode", "2.1.2.3", anything(), :port => 2020)

      subject.stub!(:git).and_return(git_handler)
      subject.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)

      subject.should_receive(:create_pushand)
      subject.run
    end
    
    it "fails when port is not numeric" do
      git_handler.stub!(:present?).and_return(:false)

      cmd = Webbynode::Commands::Init.new('2.1.2.3', '--port=nonvalid')
      cmd.stub!(:git).and_return(git_handler)
      cmd.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      
      cmd.should_receive(:puts).any_number_of_times do |str| 
        str.include?("Invalid value 'nonvalid' for option 'port'. It should be an integer.")
      end
      cmd.run
    end
  end
  
  describe '#detect_engine' do
    before(:each) do
      subject.stub!(:io).and_return(io_handler)
    end
    
    it "calls prepare once engine is detected" do
      subject.stub!(:option).with(:engine).and_return('rails')
      io_handler.should_receive(:add_setting).with('engine', 'rails')
      
      rails = double('Rails')
      rails.should_receive(:prepare)

      Webbynode::Engines::Rails.should_receive(:new).and_return(rails)
      subject.send(:detect_engine)
    end

    context 'when --engine is passed' do
      it "adds an engine setting" do
        io_handler.should_receive(:add_setting).with('engine', 'rails')
        io_handler.stub!(:add_to_git_ignore)
        
        Webbynode::Git.stub(:new).and_return(git_handler)
        Webbynode::Io.stub(:new).and_return(mock("io").as_null_object)
        
        subject.stub!(:option).with(:engine).and_return('rails')
        subject.send(:detect_engine)
      end
    
      context 'with invalid engine' do
        it "reports the error and show engines for user to choose" do
          subject.stub!(:option).with(:engine).and_return('kawaboonga')

          io_handler.should_receive(:add_setting).with('engine', 'django')
          io_handler.should_receive(:log).with("Engine 'kawaboonga' is invalid.")

          django = stub('Django').as_null_object
          django.should_receive(:engine_id).and_return('django')
          
          subject.should_receive(:choose_engine).and_return(django)
          
          subject.send(:detect_engine)
        end
      end
    end
  end

  context 'Checking prerequisites' do
    it "raises an error if git is not found" do
      io_handler.should_receive(:exec_in_path?).with('git').and_return(false)
      subject.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      lambda { subject.execute }.should raise_error(Webbynode::Command::CommandError)
    end
  end
  
  context "Engine validation" do
    context "when there is a validation error" do
      it "displays the error and exits" do
        
      end
    end
  end
  
  context "Engine detection" do
    context "when no engine was detected" do
      it "prompts for the engine" do
        io_handler.should_receive(:log).with("Supported engines:")
        io_handler.should_receive(:log).with("  1. Html")
        io_handler.should_receive(:log).with("  2. Django")
        io_handler.should_receive(:log).with("  3. WSGI")
        io_handler.should_receive(:log).with("  4. PHP")
        io_handler.should_receive(:log).with("  5. Rack")
        io_handler.should_receive(:log).with("  6. Rails 2")
        io_handler.should_receive(:log).with("  7. Rails 3")
        io_handler.should_receive(:log).with("  8. NodeJS")

        subject.should_receive(:ask).with('Select the engine your app uses:', Integer).and_return(2)

        io_handler.should_receive(:add_setting).with("engine", "django")
        io_handler.should_receive(:log).with("Initializing with Django engine...")
        Webbynode::Engines::Django.stub!(:new).and_return(double('Django').as_null_object)
        subject.run
      end
    end
    
    context "when --engine is passed" do
      subject do
        Webbynode::Commands::Init.new("--engine=php").tap do |cmd|
          webbies = {
            'sandbox' => make_webby({
              "ip"     => "201.81.121.201",
              "status" => "on",
              "name"   => "sandbox",
              "plan"   => "Webbybeta",
              "node"   => "miami-b15"
            })
          }
          api.stub!(:webbies).and_return(webbies)

          cmd.stub!(:git).and_return(git_handler)
          cmd.stub!(:io).and_return(io_handler)
          cmd.stub!(:api).and_return(api)
        end      
      end
      
      it "overrides detection" do
        io_handler.should_receive(:log).with(/Engine '.*' is invalid/).never
        io_handler.should_receive(:file_exists?).with("script/rails").never
        io_handler.should_receive(:add_setting).with("engine", "php")

        subject.should_receive(:create_pushand)
        subject.run
      end
    end
    
    it "detects Rails 3 when script/rails is present" do
      io = double("Io").as_null_object
      io.stub!(:file_exists?).with("script/rails").and_return(true)
      
      gemfile = double("Gemfile").as_null_object
      gemfile.stub!(:present?).and_return(false)

      Webbynode::Gemfile.stub(:new).and_return(gemfile)
      
      Webbynode::Io.stub(:new).and_return(io)
      io_handler.should_receive(:add_setting).with("engine", "rails3")

      subject.run
    end
    
    it "detects Rails 2 when app app/controllers and config/environent.rb are found" do
      io = double("Io").as_null_object
      io.stub(:file_exists?).with("script/rails").and_return(false)
      io.stub(:directory?).with('app').and_return(true)
      io.stub(:directory?).with('app/controllers').and_return(true)
      io.stub(:file_exists?).with('config/database.yml').and_return(false)
      io.stub(:file_exists?).with('config/environment.rb').and_return(true)

      Webbynode::Io.stub(:new).and_return(io)
      Webbynode::Git.stub(:new).and_return(git_handler)
      io_handler.should_receive(:add_setting).with("engine", "rails")

      subject.run
    end
    
    it "detects Rack when config.ru is found" do
      io = double("Io")
      io.stub!(:file_exists?).with("script/rails").and_return(false)
      io.stub!(:directory?).with('app').and_return(false)
      io.stub!(:file_exists?).with('config.ru').and_return(true)

      Webbynode::Io.stub!(:new).and_return(io)

      io_handler.should_receive(:add_setting).with("engine", "rack")

      subject.run
    end
  end
  
  context "Deployment webby" do
    it "is detected automatically if user only have one Webby" do
      git_handler.should_receive(:add_remote).with("git", "webbynode", "201.81.121.201", anything(), {})
      
      subject.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      subject.run
    end
    
    it "complains if missing and user has > 1 webby" do
      webbies = {
        'webby3' => make_webby({
          "ip"     => "67.53.31.3",
          "status" => "on",
          "name"   => "webby3",
          "plan"   => "Webbybeta",
          "node"   => "miami-b11"
        }),
        'sandbox' => make_webby({
          "ip"     => "201.81.121.201",
          "status" => "on",
          "name"   => "sandbox",
          "plan"   => "Webbybeta",
          "node"   => "miami-b15"
        }),
        'webby2' => make_webby({
          "ip"     => "67.53.31.2",
          "status" => "on",
          "name"   => "webby2",
          "plan"   => "Webbybeta",
          "node"   => "miami-b11"
        })
      }
      api.should_receive(:webbies).and_return(webbies)
      io_handler.should_receive(:log).with("Current Webbies in your account:")
      io_handler.should_receive(:log).with("  1. sandbox (201.81.121.201)")
      io_handler.should_receive(:log).with("  2. webby2 (67.53.31.2)")
      io_handler.should_receive(:log).with("  3. webby3 (67.53.31.3)")
      subject.should_receive(:ask).with("Which Webby do you want to deploy to:", Integer).and_return(2)

      io_handler.should_receive(:log).with("Set deployment Webby to webby2.")
      git_handler.should_receive(:add_remote).with("git", "webbynode", "67.53.31.2", anything(), {})
      
      subject.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      subject.run
    end
  end
  
  context "when already initialized" do
    subject do
      Webbynode::Commands::Init.new("10.0.1.1").tap do |cmd|
        cmd.stub!(:gemfile).and_return(gemfile)
        cmd.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
        cmd.stub!(:git).and_return(git_handler) 
        cmd.stub!(:io).and_return(io_handler) 
        cmd.stub(:create_pushand)
      end
    end
    
    it "doesn't ask if user already agreed to reinitialize" do
      subject.stub!(:pushand_exists?).and_return(true)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("mah_app")

      subject.should_receive(:create_pushand)

      subject.should_receive(:ask).with("Do you want to initialize it again (y/n)?").once.ordered.and_return("y")
      
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:remote_exists?).with("webbynode").and_return(true)
      git_handler.should_receive(:delete_remote).with("webbynode")

      subject.should_receive(:ask).with("Do you want to overwrite the current settings (y/n)?").never
      subject.run
    end
    
    it "keep the same remotes when answer is no to overwriting" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:remote_exists?).with("webbynode").and_return(true)
      git_handler.should_receive(:delete_remote).with("webbynode").never
      
      subject.should_receive(:ask).with("Do you want to overwrite the current settings (y/n)?").once.ordered.and_return("n")
      subject.run
    end

    it "delete webbynode remote when answer is yes to overwriting" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:remote_exists?).with("webbynode").and_return(true)
      git_handler.should_receive(:delete_remote).with("webbynode")
      
      subject.should_receive(:ask).with("Do you want to overwrite the current settings (y/n)?").once.ordered.and_return("y")
      subject.run
    end
  end
  
  context "selecting an engine" do
    it "should create the .webbynode/engine file" do
      command = Webbynode::Commands::Init.new("10.0.1.1", "--engine=php")
      command.option(:engine).should == 'php'
      command.stub!(:gemfile).and_return(gemfile)
      command.should_receive(:git).any_number_of_times.and_return(git_handler) 
      command.should_receive(:io).any_number_of_times.and_return(io_handler)
      command.stub(:create_pushand)

      io_handler.should_receive(:add_setting).with("engine", "php")
      command.run
    end
  end
  
  context "when creating a DNS entry with --adddns option" do
    let(:io) { io = double("Io").as_null_object }

    def create_init(ip="4.3.2.1", host=nil, extra=[])
      @command = Webbynode::Commands::Init.new(ip, "--dns=#{host}", *extra)
      @command.stub!(:gemfile).and_return(gemfile)
      @command.stub!(:git).and_return(git_handler) 
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      @command.stub(:create_pushand)
      @command.stub(:create_webbynode_tree)
      
      io.stub!(:file_exists?).with(".pushand").and_return(false)
    end
    
    it "should setup DNS using Webbynode API" do
      create_init("10.0.1.1", "new.rubyista.info", "--adddns")

      io.should_receive(:remove_setting).with("dns_alias")

      api = Webbynode::ApiClient.new
      api.should_receive(:create_record).with("new.rubyista.info", "10.0.1.1")
      git_handler.should_receive(:parse_remote_ip).and_return("10.0.1.1")

      @command.should_receive(:api).any_number_of_times.and_return(api)
      @command.should_receive(:io).any_number_of_times.and_return(io)
      @command.run
    end

    it "should setup empty and www records for a tld" do
      create_init("10.0.1.1", "rubyista.info", "--adddns")

      io.should_receive(:add_setting).with("dns_alias", "'www.rubyista.info'")

      api = Webbynode::ApiClient.new
      api.should_receive(:create_record).with("rubyista.info", "10.0.1.1")
      api.should_receive(:create_record).with("www.rubyista.info", "10.0.1.1")
      git_handler.should_receive(:parse_remote_ip).any_number_of_times.and_return("10.0.1.1")

      @command.should_receive(:api).any_number_of_times.and_return(api)
      @command.should_receive(:io).any_number_of_times.and_return(io)
      @command.run
    end

    it "should setup empty and www records for a non-.com tld" do
      create_init("10.0.1.1", "rubyista.com.br", "--adddns")

      # io = double("Io")
      # io.should_receive(:properties).with(".webbynode/settings").and_return(stub("Properties"))

      api = Webbynode::ApiClient.new
      api.should_receive(:create_record).with("rubyista.com.br", "10.0.1.1")
      api.should_receive(:create_record).with("www.rubyista.com.br", "10.0.1.1")
      git_handler.should_receive(:parse_remote_ip).any_number_of_times.and_return("10.0.1.1")

      @command.should_receive(:io).any_number_of_times.and_return(io)
      @command.should_receive(:api).any_number_of_times.and_return(api)
      @command.run
    end

    it "should indicate the record already exists" do
      create_init("10.0.1.1", "new.rubyista.info", "--adddns")

      api = Webbynode::ApiClient.new
      api.should_receive(:create_record).with("new.rubyista.info", "10.0.1.1").and_raise(Webbynode::ApiClient::ApiError.new("Data has already been taken"))
      git_handler.should_receive(:parse_remote_ip).and_return("10.0.1.1")

      # the DNS setting should remove any dns_aliases on .webbynode/settings
      io = Webbynode::Io.new
      io.should_receive(:remove_setting).with("dns_alias")
      io.stub!(:file_exists?).and_return(false)
      # io.should_receive(:file_exists?).with(".pushand").and_return(false)

      @command.should_receive(:api).any_number_of_times.and_return(api)
      @command.should_receive(:io).any_number_of_times.and_return(io)
      @command.run
      
      stdout.should =~ /The DNS entry for 'new.rubyista.info' already existed, ignoring./
    end

    it "should show an user friendly error" do
      create_init("10.0.1.1", "new.rubyista.info", "--adddns")

      api = Webbynode::ApiClient.new
      git_handler.should_receive(:parse_remote_ip).and_return("10.0.1.1")
      api.should_receive(:create_record).with("new.rubyista.info", "10.0.1.1").and_raise(Webbynode::ApiClient::ApiError.new("No DNS entry for id 99999"))

      # the DNS setting should remove any dns_aliases on .webbynode/settings
      io = Webbynode::Io.new
      io.should_receive(:remove_setting).with("dns_alias")
      io.stub!(:file_exists?).and_return(false)
      # io.stub!(:file_exists?).with(".pushand").and_return(false)

      @command.should_receive(:api).any_number_of_times.and_return(api)
      @command.should_receive(:io).any_number_of_times.and_return(io)
      @command.run
      
      stdout.should =~ /Couldn't create your DNS entry: No DNS entry for id 99999/
    end
  end
  
  it "should report Webby doesn't exist" do
    api = double("ApiClient")
    api.should_receive(:ip_for).with("my_webby_name").and_return(nil)
    api.should_receive(:webbies).and_return({
      "one_webby"=>{:name => 'one_webby', :other => 'other'}, 
      "another_webby"=>{:name => 'another_webby', :other => 'other'}
    })
    
    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")

    create_init("my_webby_name")
    @command.should_receive(:api).any_number_of_times.and_return(api)
    @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
    @command.run
    
    stdout.should =~ /Couldn't find Webby 'my_webby_name' on your account. Your Webbies are/
    stdout.should =~ /'one_webby'/
    stdout.should =~ /' and '/
    stdout.should =~ /'another_webby'/
  end
  
  it "should report user doesn't have Webbies" do
    api = double("ApiClient")
    api.should_receive(:ip_for).with("my_webby_name").and_return(nil)
    api.should_receive(:webbies).and_return({})
    
    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")

    create_init("my_webby_name")
    @command.should_receive(:api).any_number_of_times.and_return(api)
    @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
    @command.run
    
    stdout.should =~ /You don't have any active Webbies on your account./
  end
  
  it "should try to get Webby's IP if no IP given" do
    api = double("ApiClient")
    api.stub!(:webbies).and_return(['a', 'b'])
    api.should_receive(:ip_for).with("my_webby_name").and_return("1.2.3.4")
    
    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
    git_handler.should_receive(:present?).and_return(false)
    git_handler.should_receive(:add_remote).with("git", "webbynode", "1.2.3.4", "my_app", {})

    create_init("my_webby_name")
    @command.stub!(:api).and_return(api)
    @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
    @command.run
  end
  
  context "determining host" do
    it "should assume host is app's name when not given" do
      @command.should_receive(:pushand_exists?).any_number_of_times.and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("application_name")

      pushand.should_receive(:create!).with("application_name", "application_name")
    
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      @command.run
    end
  
    it "should assume host is app's name when not given" do
      create_init("1.2.3.4", "my.com.br")
      
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("application_name")
      
      pushand.should_receive(:create!).with("application_name", "my.com.br")
    
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      @command.run
    end
  end
  
  context "when .webbynode is not present" do
    let(:io)  { double('io').as_null_object }
    let(:git) { double('git').as_null_object }
    subject do 
      Webbynode::Commands::Init.new("10.0.1.1").tap do |cmd|
        cmd.stub!(:io).and_return(io)
        cmd.stub!(:git).and_return(git)
        cmd.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
        cmd.stub!(:ask)
      end
    end
    
    before(:each) do
      git.stub(:remote_exists?).and_return(false)
      subject.should_receive(:pushand_exists?).any_number_of_times.and_return(false)
      subject.stub(:create_pushand)
    end

    it "creates the .webbynode system folder and stub files" do
      io.should_receive(:mkdir).with(".webbynode/tasks")

      io.should_receive(:create_if_missing).with(".webbynode/tasks/after_push", "")
      io.should_receive(:create_if_missing).with(".webbynode/tasks/before_push", "")
      io.should_receive(:create_if_missing).with(".webbynode/aliases", "")
      io.should_receive(:create_if_missing).with(".webbynode/config", "")
      
      subject.run
    end
  end
  
  context "when .pushand is not present" do
    before(:each) do
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
    end

    it "should be created and made an executable" do
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("mah_app")
      pushand.should_receive(:create!).with("mah_app", "mah_app")
      
      @command.run
    end
  end
  
  context "when .pushand is present" do
    before(:each) do
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
    end

    it "isn't replaced if user answers no" do
      @command.stub(:pushand_exists?).and_return(true)
      # io_handler.should_receive(:create_file).with(".pushand").never
      io_handler.should_receive(:log).with("It seems this application was initialized before.")
      @command.should_receive(:ask).with("Do you want to initialize it again (y/n)?").once.ordered.and_return("n")
      
      lambda { @command.execute }.should raise_error(Webbynode::Command::CommandError)
    end

    it "is replaced if user answers yes" do
      @command.stub(:pushand_exists?).and_return(true)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("mah_app")
      pushand.should_receive(:create!).with("mah_app", "mah_app")
      
      io_handler.should_receive(:log).with("Commiting Webbynode changes...")
      git_handler.should_receive(:add).with(".")
      git_handler.should_receive(:commit2).with("[Webbynode] Rapid App Deployment Reinitialization")

      @command.should_receive(:ask).with("Do you want to initialize it again (y/n)?").once.ordered.and_return("y")
      
      @command.run
    end
  end
  
  context "when git repo doesn't exist yet" do
    before(:each) do
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      @command.stub!(:create_pushand)
    end

    it "should create a new git repo" do
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:init)

      @command.run
    end
    
    it "should add a new remote" do
      io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:add_remote).with("git", "webbynode", "4.3.2.1", "my_app", {})

      @command.run
    end
    
    it "should add everything" do
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:add).with(".")

      @command.run
    end
  
    it "should create the initial commit" do
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:commit).with("Initial commit")
      
      @command.run
    end
    
    it "should log a message to the user when it's finished" do
      io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
      io_handler.should_receive(:log).with("Application my_app ready for Rapid Deployment", :finish)
      
      @command.run
    end
  end

  context "when git repo is initialized" do
    before(:each) do
      @command.stub!(:detect_engine).and_return(Webbynode::Engines::Rails)
      @command.stub!(:create_pushand)
    end
    
    it "complains if git is in a dirty state" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:clean?).and_return(false)
      
      lambda { @command.execute }.should raise_error(Webbynode::Command::CommandError,
        "Cannot initialize: git has pending changes.\nExecute a git commit or add changes to .gitignore and try again.")
    end
    
    it "shows that a commit is being added" do
      io_handler.should_receive(:log).with("Commiting Webbynode changes...")
      git_handler.should_receive(:present?).and_return(true)
      
      @command.run
    end
    
    it "adds pending changes" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:add).with(".")

      @command.run
    end
    
    it "commits the changes" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:commit2).with("[Webbynode] Rapid App Deployment Reinitialization")

      @command.run
    end

    it "should try to add a remote" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:add_remote)

      @command.run
    end
    
    it "should tell the user it's already initialized" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:add_remote).and_raise(Webbynode::GitRemoteAlreadyExistsError)
      
      io_handler.should_receive(:log).with("Application already initialized.")
      @command.run
    end
  end
end
