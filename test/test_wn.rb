require File.dirname(__FILE__) + '/test_helper.rb'

class TestWn < Test::Unit::TestCase
  
  def command(s)
    Wn::App.new(s.split(" "))
  end

  context "Parsing commands" do
    should "trigger the proper method" do
      app = command("init")
      app.expects(:init)
      app.run
    
      app = command("push")
      app.expects(:push)
      app.run
    end
    
    should "separate commands and parameters" do
      app = command("init myshot.com")
      app.command.should == "init"
      app.params.should == ["myshot.com"]
    end
  end
  
  context "File exists" do
    should "be true if file exists" do
      File.expects(:exists?).with(".pushand").returns(true)
      app = Wn::App.new(["abcdef"])
      app.file_exists(".pushand").should == true
    end
  
    should "be false if file exists" do
      File.expects(:exists?).with(".gitignore").returns(false)
      app = Wn::App.new(["abcdef"])
      app.file_exists(".gitignore").should == false
    end
  end
  
  context "Dir exists" do
    should "be true if dir exists" do
      File.expects(:directory?).with(".git").returns(true)
      app = Wn::App.new(["abcdef"])
      app.dir_exists(".git").should == true

      File.expects(:directory?).with(".gita").returns(false)
      app = Wn::App.new(["abcdef"])
      app.dir_exists(".gita").should == false
    end
  end
  
  context "Out" do
    app = Wn::App.new(["abcdef"])
    app.expects(:puts).with("help!")
    app.out "help!"

    app = Wn::App.new(["abcdef"])
    app.expects(:puts).with("help me!")
    app.out "help me!"
  end
  
  context "Create file" do
    should "create a file with the given contexts" do
      app = Wn::App.new(["abcdef"])

      file = mock("file")
      File.expects(:open).with("/var/rails/my_gosh", "w").yields(file)
      file.expects(:write).with("my\nfair\nlady")
      app.create_file "/var/rails/my_gosh", "my\nfair\nlady"

      file = mock("file")
      File.expects(:open).with("/var/rails/yahoo", "w").yields(file)
      file.expects(:write).with("another_brick_in_the_wall")
      app.create_file "/var/rails/yahoo", "another_brick_in_the_wall"
    end
  end
  
  context "Git init" do
    should "call git init and commit initial commit" do
      app = Wn::App.new(["abcdef"])
      app.expects(:sys_exec).with("git init")

      app.expects(:app_name).with().returns("my_app")
      app.expects(:sys_exec).with("git remote add webbynode git@2.2.3.3:my_app")

      app.expects(:sys_exec).with("git add .")
      app.expects(:sys_exec).with("git commit -m \"Initial commit\"")

      app.git_init "2.2.3.3"
      
      app = Wn::App.new(["abcdef"])
      app.expects(:sys_exec).with("git init")

      app.expects(:app_name).with().returns("another_app")
      app.expects(:sys_exec).with("git remote add webbynode git@5.4.2.1:another_app")

      app.expects(:sys_exec).with("git add .")
      app.expects(:sys_exec).with("git commit -m \"Initial commit\"")

      app.git_init "5.4.2.1"
    end
  end
  
  context "Push command" do
    should "push to webbynode master" do
      app = command("push")
      app.expects(:dir_exists).with(".git").returns(true)
      app.expects(:app_name).with().returns("another_app")
      app.expects(:out).with("Publishing another_app to Webbynode...")
      app.expects(:sys_exec).with("git push webbynode master")
      app.run
    end
    
    should "indicate not initialized" do
      app = command("push")
      app.expects(:dir_exists).with(".git").returns(false)
      app.expects(:out).with("Not an application or missing initialization. Use 'webbynode init'.")
      app.run
    end
  end
  
  context "Init command" do
    should "require one arguments" do
      app = command("init")
      app.expects(:out).with("usage: webbynode init webby_ip [host]")
      app.run
    end
    
    should "create .gitignore" do
      app = command("init 2.2.2.2 teste.myserver.com")
      app.expects(:out).with("Creating .gitignore file...")
      app.expects(:dir_exists).with(".git").times(2).returns(true)
      app.expects(:out).with("Adding Webbynode remote host to git...")
      app.expects(:file_exists).with(".pushand").returns(true)
      app.expects(:file_exists).with(".gitignore").returns(false)
      app.expects(:create_file).with(".gitignore", <<EOS)
config/database.yml
log/*
tmp/*
db/*.sqlite3
EOS

      app.expects(:app_name).with().returns("teste.myserver.com")
      app.expects(:sys_exec).with("git remote add webbynode git@2.2.2.2:teste_myserver_com")
      app.expects(:sys_exec).with("git add .")
      app.expects(:sys_exec).with("git commit -m \"Initial commit\"")
      
      app.run
      
      app = command("init 2.2.2.2")
      app.expects(:out).with("Creating .gitignore file...")
      app.expects(:app_name).with().returns("myapp")
      app.expects(:dir_exists).with(".git").returns(true)
      app.expects(:file_exists).with(".pushand").returns(true)
      app.expects(:file_exists).with(".gitignore").returns(false)
      app.expects(:create_file).with(".gitignore", <<EOS)
config/database.yml
log/*
tmp/*
db/*.sqlite3
EOS
      app.run
    end
    
    should "create .pushand with host if missing" do
      app = command("init 2.2.2.2 teste.myserver.com")
      
      app.expects(:dir_exists).with(".git").returns(false)
      app.expects(:out).with("Initializing git repository...")
      app.expects(:git_init).with("2.2.2.2")
      
      app.expects(:out).with("Initializing deployment descriptor for teste.myserver.com...")
      app.expects(:file_exists).with(".gitignore").returns(true)
      app.expects(:file_exists).with(".pushand").returns(false)
      app.expects(:sys_exec).with("chmod +x .pushand")
      app.expects(:create_file).with(".pushand", <<EOS)
#! /bin/bash
phd $0 teste.myserver.com
EOS
      app.run 
    end

    should "create .pushand with app name as the host if not specified" do
      app = command("init 3.3.3.3")

      app.expects(:dir_exists).with(".git").returns(true)
      app.expects(:out).with("Adding Webbynode remote host to git...")
      app.expects(:app_name).with().times(2).returns("myapp")
      
      app.expects(:sys_exec).with("git remote add webbynode git@3.3.3.3:myapp")
      app.expects(:sys_exec).with("git add .")
      app.expects(:sys_exec).with("git commit -m \"Initial commit\"")

      app.expects(:out).with("Initializing deployment descriptor for myapp...")
      app.expects(:file_exists).with(".gitignore").returns(true)
      app.expects(:file_exists).with(".pushand").returns(false)
      app.expects(:sys_exec).with("chmod +x .pushand")
      app.expects(:create_file).with(".pushand", <<EOS)
#! /bin/bash
phd $0 myapp
EOS
      app.run
    end

    should "tell the app has already been initialized" do
      app = command("init 5.5.5.5 teste.myserver.com")
      app.expects(:dir_exists).times(2).with(".git").returns(true)
      app.expects(:file_exists).with(".pushand").returns(true)
      app.expects(:file_exists).with(".gitignore").returns(true)
      app.expects(:create_file).never

      app.expects(:sys_exec).with("git remote add webbynode git@5.5.5.5:webbynode")
      app.expects(:sys_exec).with("git add .")
      app.expects(:sys_exec).with("git commit -m \"Initial commit\"")
      app.run
    end
  end
  
end
