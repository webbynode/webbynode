# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Io do
  describe '#sed' do
    it 'replaces a regexp' do
      text = read_fixture('settings.py')
      File.should_receive(:read).with('settings.template.py').and_return(text)      
      File.should_receive(:open).with('settings.template.py', 'w').and_yield(file = double('File'))
      file.should_receive(:write) do |contents| 
        pass = contents.include?("'ENGINE': '@app_engine'")
      end
      
      output = subject.sed('settings.template.py', /'ENGINE': '[^ ,]*'/, "'ENGINE': '@app_engine@'")
      # output.should =~ /'ENGINE': '@app_engine@'/
    end
  end
  
  describe '#copy_file' do
    it "copies the file" do
      FileUtils.should_receive(:cp).with('settings.py', 'settings.template.py')
      subject.copy_file 'settings.py', 'settings.template.py'
    end
  end
  
  describe "#app_name" do
    context "when successful" do
      it "should return the current folder" do
        Dir.should_receive(:pwd).and_return("/some/deep/folder/where/you/find/app_name")
        Webbynode::Io.new.app_name.should == "app_name"
      end

      it "should transform dots and spaces into underscores" do
        Dir.should_receive(:pwd).and_return("/some/deep/folder/where/you/find/my.app here")
        Webbynode::Io.new.app_name.should == "my_app_here"
      end
    end
  end
  
  describe '#add_setting' do
    let(:io) { Webbynode::Io.new }
    
    it "creates .webbynode directory if needed" do
      io.should_receive(:properties).with(".webbynode/settings").and_return(stub('props').as_null_object)
      io.should_receive(:directory?).with(".webbynode").and_return(false)
      io.should_receive(:mkdir).with(".webbynode")
      io.add_setting("engine", "php")
    end

    it "should add a key to the property file .webbynode/settings" do
      props = mock("Hash")
      props.should_receive(:[]=).with("engine", "php")
      props.should_receive(:save)
      
      io.should_receive(:properties).with(".webbynode/settings").and_return(props)
      io.add_setting("engine", "php")
    end
  end
  
  describe '#add_multi_setting' do
    let(:io) { Webbynode::Io.new }
    it "creates an entry with the elements" do
      props = mock("Hash")
      props.should_receive(:[]=).with('addons', '(a b c)')
      props.should_receive(:save)

      io.should_receive(:properties).with(".webbynode/settings").and_return(props)
      io.add_multi_setting("addons", ['a', 'b', 'c'])
    end
  end
  
  describe '#load_setting' do
    let(:io) { Webbynode::Io.new }
    it "loads the properties file" do
      props = stub("Properties")
      props.should_receive(:[]).with('addons').and_return(['a', 'b', 'c'])

      # Properties.should_receive(:initialize).with(".webbynode/settings", true).and_return(props)
      io.should_receive(:properties).with(".webbynode/settings").and_return(props)
      io.load_setting("addons").should == ['a', 'b', 'c']
    end
  end
  
  describe '#remove_setting' do
    let(:io) { Webbynode::Io.new }

    it "should add a key to the property file .webbynode/settings" do
      props = mock("Hash")
      props.should_receive(:remove).with("engine")
      props.should_receive(:save)
      
      io.should_receive(:properties).with(".webbynode/settings").and_return(props)
      io.remove_setting("engine")
    end
  end
  
  describe '#create_local_key' do
    describe "when key file missing" do
      before(:each) do
        File.should_receive(:exists?).with(LocalSshKey).and_return(false)
        @io = Webbynode::Io.new
      end

      context "with no passphrase" do
        it "should create the key with an empty passphrase" do
          @io.should_receive(:mkdir).with(File.dirname(LocalSshKey))
          @io.should_receive(:exec).with(%Q(ssh-keygen -t rsa -N "" -f "#{LocalSshKey.gsub(/\.pub$/, "")}")).and_return("")
          @io.create_local_key
        end
      end
      
      context "with a passphrase" do
        it "should create the key with the provided passphrase" do
          @io.should_receive(:mkdir).with(File.dirname(LocalSshKey))
          @io.should_receive(:exec).with(%Q(ssh-keygen -t rsa -N "passphrase" -f "#{LocalSshKey.gsub(/\.pub$/, "")}")).and_return("")
          @io.create_local_key("passphrase")
        end
      end
    end
    
    describe "when key already exists" do
      before(:each) do
        File.should_receive(:exists?).with(LocalSshKey).and_return(true)
        @io = Webbynode::Io.new
      end

      it "should just skip the creation" do
        @io.should_receive(:exec).never
        @io.create_local_key
      end
    end
  end
  
  describe '#file_exists?' do
    before(:each) do; @io = Webbynode::Io.new; end
    
    it "should return true if file exists" do
      File.should_receive(:exists?).with("file").and_return(true)
      @io.file_exists?("file").should be_true
    end
    
    it "should return false if file doesn't exist" do
      File.should_receive(:exists?).with("file").and_return(false)
      @io.file_exists?("file").should be_false
    end
  end
    
  describe '#templates_path' do
    it "should return the contents of TemplatesPath" do
      io = Webbynode::Io.new
      io.templates_path.should == Webbynode::Io::TemplatesPath
    end
  end
  
  describe '#create_from_template' do
    it "should read the template and write a new file with its contents" do
      io = Webbynode::Io.new
      io.should_receive(:read_from_template).with("template_file").and_return("template_file_contents")
      io.should_receive(:create_file).with("output_file", "template_file_contents")
      io.create_from_template("output_file", "template_file")
    end
  end
  
  describe '#read_from_template' do
    it "should read a file from the templates path" do
      io = Webbynode::Io.new
      io.should_receive(:templates_path).and_return("/templates")
      io.should_receive(:read_file).with("/templates/template_file").and_return("template_contents")
      io.read_from_template("template_file").should == "template_contents"
    end
  end
  
  describe '#add_line' do
    before(:each) do
      subject.stub(:create_if_missing)
    end
    
    context "when file doesn't exist yet" do
      it "creates the file" do
        file = stub('file')
        
        File.should_receive(:read).with('.gitignore').and_return('')
        
        File.should_receive(:open).with('.gitignore', 'a').and_yield(file)
        file.should_receive(:puts).with('new_line')

        subject.should_receive(:create_if_missing).with(".gitignore")
        subject.add_line '.gitignore', 'new_line'
      end
    end
    
    context "when line doesn't exist yet" do
      it "adds one line to a file" do
        file = stub('file')
        
        File.should_receive(:read).with('.gitignore').and_return('')
        
        File.should_receive(:open).with('.gitignore', 'a').and_yield(file)
        file.should_receive(:puts).with('new_line')
        
        subject.add_line '.gitignore', 'new_line'
      end
    end
    
    context 'when line exists' do
      it "doesn't add the line again" do
        File.should_receive(:read).with('.gitignore').and_return('new_line')
        File.should_receive(:open).with('.gitignore', 'a').never
        
        subject.add_line '.gitignore', 'new_line'
      end
    end
  end
  
  describe '#create_file' do
    it "should create a file with specified contents" do
      file = double("File")
      File.should_receive(:open).with("file_to_write", "w").and_yield(file)
      file.should_receive(:write).with("file_contents")

      io = Webbynode::Io.new
      io.create_file("file_to_write", "file_contents")
    end
    
    it "should accept an optional executable parameter" do
      file = double("File")
      File.should_receive(:open).with("file_to_write", "w").and_yield(file)
      file.should_receive(:write).with("file_contents")
      
      FileUtils.should_receive(:chmod).with(0755, "file_to_write")

      io = Webbynode::Io.new
      io.create_file("file_to_write", "file_contents", true)
    end
  end
  
  describe '#create_if_missing' do
    it "creates the file if it doesn't exist" do
      subject.should_receive(:file_exists?).with("a").and_return(false)
      subject.should_receive(:create_file).with("a", "contents", true)
      subject.create_if_missing("a", "contents", true)
    end
    
    it "does nothing if file exists" do
      subject.should_receive(:file_exists?).with("a").and_return(true)
      subject.should_receive(:create_file).never
      subject.create_if_missing("a", "contents")
    end
  end
  
  describe "#exec" do
    context "when successful" do
      it "should execute the command and retrieve the output" do
        io = Webbynode::Io.new
        io.should_receive(:`).with("ls -la 2>&1").and_return("output for ls -la")
        io.exec("ls -la").should == "output for ls -la"
      end
    end
  end
  
  describe "#exec3" do
    context "when successful" do
      it "executes the command and retrieve the output and exit code" do
        io = Webbynode::Io.new
        io.should_receive(:`).with("ls -la").and_return("output for ls -la")
        io.exec3("ls -la").should == [false, "output for ls -la"]
      end
    end
  end
  
  describe "#read_file" do
    context "when successful" do
      it "should return file contents" do
        io = Webbynode::Io.new
        File.should_receive(:read).with("filename").and_return("file contents")
        io.read_file("filename").should == "file contents"
      end
    end
  end
  
  describe "#directory?" do
    context "when successful" do
      it "should return true when item is a directory" do
        File.should_receive(:directory?).with("dir").and_return(true)

        io = Webbynode::Io.new
        io.directory?("dir").should == true
      end

      it "should return false when item is not a directory" do
        File.should_receive(:directory?).with("dir").and_return(false)

        io = Webbynode::Io.new
        io.directory?("dir").should == false
      end
    end
  end
  
  describe "#open_file" do
    it "should open the file" do
      io = Webbynode::Io.new
      File.should_receive(:open).with("filename", anything).and_return("file contents")
      io.open_file("filename", anything).should eql("file contents")
    end
  end
  
  describe "#read_config" do
    it "should parse value = key pairs" do
      io = Webbynode::Io.new
      io.should_receive(:read_file).with("config").and_return("a = b\nc = d\nother = rest")
      
      cfg = io.read_config("config")
      cfg[:a].should == "b"
      cfg[:c].should == "d"
      cfg[:other].should == "rest"
    end
  end
end