# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Init do
  let(:git_handler) { double("git").as_null_object }
  let(:io_handler)  { double("io").as_null_object }
  let(:gemfile)     { double("gemfile").as_null_object.tap { |g| g.stub!(:present?).and_return(false) } }
  
  def create_init(ip="4.3.2.1", host=nil, extra=[])
    host = "--dns=#{host}" if host
    @command = Webbynode::Commands::Init.new(ip, host, *extra)
    @command.stub!(:gemfile).and_return(gemfile)
    @command.should_receive(:git).any_number_of_times.and_return(git_handler) 
    @command.should_receive(:io).any_number_of_times.and_return(io_handler)
  end
  
  before(:each) do
    FakeWeb.clean_registry
    create_init
    git_handler.stub!(:remote_exists?).and_return(false)
  end
  
  context "Deployment webby" do
    let(:api) { double("api").as_null_object }
    subject do
      Webbynode::Commands::Init.new.tap do |cmd|
        cmd.stub!(:git).and_return(git_handler)
        cmd.stub!(:io).and_return(io_handler)
        cmd.stub!(:api).and_return(api)
      end      
    end
    
    it "is detected automatically if user only have one Webby" do
      webbies = {
        'sandbox' => {
          :ip     => "201.81.121.201",
          :status => "on",
          :name   => "sandbox",
          :notes  => "",
          :plan   => "Webbybeta",
          :node   => "miami-b15"
        }
      }
      api.should_receive(:webbies).and_return(webbies)
      git_handler.should_receive(:add_remote).with("webbynode", "201.81.121.201", anything())
      
      subject.run
    end
    
    it "complains if missing and user has > 1 webby" do
      webbies = {
        'webby3' => {
          :ip     => "67.53.31.3",
          :status => "on",
          :name   => "webby3",
          :notes  => "",
          :plan   => "Webbybeta",
          :node   => "miami-b11"
        },
        'sandbox' => {
          :ip     => "201.81.121.201",
          :status => "on",
          :name   => "sandbox",
          :notes  => "",
          :plan   => "Webbybeta",
          :node   => "miami-b15"
        },
        'webby2' => {
          :ip     => "67.53.31.2",
          :status => "on",
          :name   => "webby2",
          :notes  => "",
          :plan   => "Webbybeta",
          :node   => "miami-b11"
        }
      }
      api.should_receive(:webbies).and_return(webbies)
      io_handler.should_receive(:log).with("Current Webbies in your account:", :action)
      io_handler.should_receive(:log).with("  1. sandbox (201.81.121.201)", :action)
      io_handler.should_receive(:log).with("  2. webby2 (67.53.31.2)", :action)
      io_handler.should_receive(:log).with("  3. webby3 (67.53.31.3)", :action)
      subject.should_receive(:ask).with("Which webby do you want to deploy to:")
      
      # git_handler.should_receive(:add_remote).never
      
      subject.run
    end
  end
  
  context "Gemfile checking" do
    context "when present" do
      it "complains if there is a sqlite3-ruby dependency outside of development and test groups" do
        gemfile.should_receive(:present?).and_return(true)
        gemfile.should_receive(:dependencies).and_return(['sqlite3-ruby', 'mysql'])
        
        lambda { @command.execute }.should raise_error(Webbynode::Command::CommandError)
      end
    end
  end
  
  context "Rails3 auto detection" do
    context "when script/rails is present" do
      it "makes engine=rails3 implicitly" do
        io_handler.stub!(:file_exists?).with("script/rails").and_return(true)
        io_handler.should_receive(:add_setting).with("engine", "rails3")
        
        @command.run
      end
    end
  end
  
  context "when already initialized" do
    it "keep the same remotes when answer is no to overwriting" do
      command = Webbynode::Commands::Init.new("10.0.1.1")
      command.stub!(:gemfile).and_return(gemfile)
      command.should_receive(:git).any_number_of_times.and_return(git_handler) 
      command.should_receive(:ask).with("Webbynode already initialized. Do you want to overwrite the current settings (y/n)?").once.ordered.and_return("n")

      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:remote_exists?).with("webbynode").and_return(true)
      git_handler.should_receive(:delete_remote).with("webbynode").never
      
      command.run
    end

    it "delete webbynode remote when answer is yes to overwriting" do
      command = Webbynode::Commands::Init.new("10.0.1.1")
      command.stub!(:gemfile).and_return(gemfile)
      command.should_receive(:git).any_number_of_times.and_return(git_handler) 
      command.should_receive(:ask).with("Webbynode already initialized. Do you want to overwrite the current settings (y/n)?").once.ordered.and_return("y")

      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:remote_exists?).with("webbynode").and_return(true)
      git_handler.should_receive(:delete_remote).with("webbynode")
      
      command.run
    end
  end
  
  context "selecting an engine" do
    it "should create the .webbynode/engine file" do
      command = Webbynode::Commands::Init.new("10.0.1.1", "--engine=php")
      command.option(:engine).should == 'php'
      command.stub!(:gemfile).and_return(gemfile)
      command.should_receive(:git).any_number_of_times.and_return(git_handler) 
      command.should_receive(:io).any_number_of_times.and_return(io_handler)

      io_handler.should_receive(:add_setting).with("engine", "php")
      command.run
    end
  end
  
  context "when creating a DNS entry with --adddns option" do
    let(:io) { io = double("Io").as_null_object }

    def create_init(ip="4.3.2.1", host=nil, extra=[])
      @command = Webbynode::Commands::Init.new(ip, "--dns=#{host}", *extra)
      @command.stub!(:gemfile).and_return(gemfile)
      @command.should_receive(:git).any_number_of_times.and_return(git_handler) 
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

      @command.should_receive(:api).any_number_of_times.and_return(api)
      @command.should_receive(:io).any_number_of_times.and_return(io)
      @command.run
      
      stdout.should =~ /Couldn't create your DNS entry: No DNS entry for id 99999/
    end
  end
  
  it "should ask for user's login email if no credentials" do
    FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/webbies", 
      :email => "fcoury@me.com", :response => read_fixture("api/webbies"))

    io_handler.should_receive(:file_exists?).with(Webbynode::ApiClient::CREDENTIALS_FILE).and_return(false)
    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")

    props = {}
    props.stub(:save)

    create_init("my_webby_name")
    @command.api.should_receive(:io).any_number_of_times.and_return(io_handler)
    @command.api.should_receive(:ask).with("API token:   ").and_return("234def")
    @command.api.should_receive(:ask).with("Login email: ").and_return("abc123")
    @command.api.should_receive(:properties).any_number_of_times.and_return(props)
    @command.run
    
    stdout.should =~ /Couldn't find Webby 'my_webby_name' on your account. Your Webbies are/
    stdout.should =~ /'webby3067'/
    stdout.should =~ /' and '/
    stdout.should =~ /'sandbox'/
  end
  
  it "should report the error if user provides wrong credentials" do
    FakeWeb.register_uri(:post, "#{Webbynode::ApiClient.base_uri}/webbies", 
      :email => "fcoury@me.com", :response => read_fixture("api/webbies_unauthorized"))

    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
    io_handler.should_receive(:create_file).never

    create_init("my_webby_name")

    @command.api.should_receive(:ip_for).and_raise(Webbynode::ApiClient::Unauthorized)
    @command.run

    stdout.should =~ /Your credentials didn't match any Webbynode account./
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
    @command.run
    
    stdout.should =~ /You don't have any active Webbies on your account./
  end
  
  it "should try to get Webby's IP if no IP given" do
    api = double("ApiClient")
    api.stub!(:webbies).and_return(['a', 'b'])
    api.should_receive(:ip_for).with("my_webby_name").and_return("1.2.3.4")
    
    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
    git_handler.should_receive(:present?).and_return(false)
    git_handler.should_receive(:add_remote).with("webbynode", "1.2.3.4", "my_app")

    create_init("my_webby_name")
    @command.stub!(:api).and_return(api)
    @command.run
  end
  
  context "determining host" do
    it "should assume host is app's name when not given" do
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("application_name")
      io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 application_name application_name\n", true)
    
      @command.run
    end
  
    it "should assume host is app's name when not given" do
      create_init("1.2.3.4", "my.com.br")
      
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("application_name")
      io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 application_name my.com.br\n", true)
    
      @command.run
    end
  end
  
  context "when .gitignore is not present" do
    it "should create the standard .gitignore" do
      io_handler.should_receive(:file_exists?).with(".gitignore").and_return(false)
      git_handler.should_receive(:add_git_ignore)
      
      @command.run
    end
  end
  
  context "when .gitignore is present" do
    context "when config/database.yml is already tracked by git" do
      it "stops tracking config/database.yml" do
        git_handler.should_receive(:tracks?).with("config/database.yml").and_return(true)
        git_handler.should_receive(:remove).with("config/database.yml")
      
        @command.run
      end
    end
    
    context "when config/database.yml is not tracked by git" do
      it "doesn't stop tracking config/database.yml" do
        git_handler.should_receive(:tracks?).with("config/database.yml").and_return(false)
        git_handler.should_receive(:remove).with("config/database.yml").never
      
        @command.run
      end
    end
    
    context "when db/schema.rb is already tracked by git" do
      it "stops tracking db/schema.rb" do
        git_handler.should_receive(:tracks?).with("db/schema.rb").and_return(true)
        git_handler.should_receive(:remove).with("db/schema.rb")
      
        @command.run
      end
    end
    
    context "when db/schema.rb is not tracked by git" do
      it "doesn't stop tracking db/schema.rb" do
        git_handler.should_receive(:tracks?).with("db/schema.rb").and_return(false)
        git_handler.should_receive(:remove).with("db/schema.rb").never
      
        @command.run
      end
    end
    
    it "adds config/database.yml to .gitconfig" do
      io_handler.should_receive(:file_exists?).with(".gitignore").and_return(true)
      git_handler.should_receive(:add_to_git_ignore).with("config/database.yml", "db/schema.rb")
      
      @command.run
    end
  end
  
  context "when .webbynode is not present" do
    it "should create the .webbynode system folder and stub files" do
      io_handler.should_receive(:directory?).with(".webbynode").and_return(false)
      io_handler.should_receive(:exec).with("mkdir -p .webbynode/tasks")
      io_handler.should_receive(:create_file).with(".webbynode/tasks/after_push", "")
      io_handler.should_receive(:create_file).with(".webbynode/tasks/before_push", "")
      io_handler.should_receive(:create_file).with(".webbynode/aliases", "")
      
      @command.run
    end
  end
  
  context "when .pushand is not present" do
    it "should be created and made an executable" do
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("mah_app")
      io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 mah_app mah_app\n", true)
      
      @command.run
    end
  end
  
  context "when .pushand is present" do
    it "should not be created" do
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(true)
      io_handler.should_receive(:create_file).never
      
      @command.run
    end
  end
  
  context "when git repo doesn't exist yet" do
    it "should create a new git repo" do
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:init)

      @command.run
    end
    
    it "should add a new remote" do
      io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
      git_handler.should_receive(:present?).and_return(false)
      git_handler.should_receive(:add_remote).with("webbynode", "4.3.2.1", "my_app")

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
    it "complains if git is in a dirty state" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:clean?).and_return(false)
      
      lambda { @command.execute }.should raise_error(Webbynode::Command::CommandError,
        "Cannot initialize: git has pending changes. Execute a git commit or add changes to .gitignore and try again.")
    end
    
    it "shows that a commit is being added" do
      io_handler.should_receive(:log).with("Commiting Webbynode changes...", :action)
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
      git_handler.should_receive(:commit2).with("[Webbynode] Rapid App Deployment Initialization")

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
      
      io_handler.should_receive(:log).with("Application already initialized.", true)
      @command.run
    end
  end
end
