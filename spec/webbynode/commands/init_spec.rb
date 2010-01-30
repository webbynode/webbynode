# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Init do
  let(:git_handler) { double("dummy_git_handler").as_null_object }
  let(:io_handler)  { double("dummy_io_handler").as_null_object }
  
  def create_init(ip="4.3.2.1", host=nil)
    @command = Webbynode::Commands::Init.new(ip, host)
    @command.should_receive(:git).any_number_of_times.and_return(git_handler) 
    @command.should_receive(:io).any_number_of_times.and_return(io_handler)
  end
  
  before(:each) do
    create_init
  end
  
  it "should output usage if no params given" do
    pending "improve handling of missing commands"
    command = Webbynode::Commands::Init.new
    command.run
    stdout.should =~ /Usage: webbynode init webby \[dns\]/
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
    api.should_receive(:ip_for).with("my_webby_name").and_return("1.2.3.4")
    
    io_handler.should_receive(:app_name).any_number_of_times.and_return("my_app")
    git_handler.should_receive(:present?).and_return(false)
    git_handler.should_receive(:add_remote).with("webbynode", "1.2.3.4", "my_app")

    create_init("my_webby_name")
    @command.should_receive(:api).and_return(api)
    @command.run
  end
  
  context "determining host" do
    it "should assume host is app's name when not given" do
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("application_name")
      io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 application_name\n")
    
      @command.run
    end
  
    it "should assume host is app's name when not given" do
      create_init("1.2.3.4", "my.com.br")
      
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("application_name")
      io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 my.com.br\n")
    
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
  
  context "when .webbynode is not present" do
    it "should create the .webbynode system folder" do
      io_handler.should_receive(:directory?).with(".webbynode").and_return(false)
      io_handler.should_receive(:exec).with("mkdir .webbynode")
      
      @command.run
    end
  end
  
  context "when .pushand is not present" do
    it "should be created" do
      io_handler.should_receive(:file_exists?).with(".pushand").and_return(false)
      io_handler.should_receive(:app_name).any_number_of_times.and_return("mah_app")
      io_handler.should_receive(:create_file).with(".pushand", "#! /bin/bash\nphd $0 mah_app\n")
      
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
      io_handler.should_receive(:log).with("Webbynode has been initialized for this application!", true)
      
      @command.run
    end
  end

  context "when git repo is initialized" do
    it "should not create a commit" do
      git_handler.should_receive(:present?).and_return(true)
      git_handler.should_receive(:commit).never

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
      
      io_handler.should_receive(:log).with("Webbynode already initialized for this application.", true)
      @command.run
    end
  end
end
