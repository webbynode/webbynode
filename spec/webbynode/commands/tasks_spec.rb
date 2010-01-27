# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Tasks do
  
  it "should have constants defining the paths to the task files" do
    tasks_class = Webbynode::Commands::Tasks
    tasks_class::TasksPath.should             eql(".webbynode/tasks")
    tasks_class::BeforeCreateTasksFile.should eql(".webbynode/tasks/before_create")
    tasks_class::AfterCreateTasksFile.should  eql(".webbynode/tasks/after_create")
    tasks_class::BeforePushTasksFile.should   eql(".webbynode/tasks/before_push")
    tasks_class::AfterPushTasksFile.should    eql(".webbynode/tasks/after_push")
  end
  
  let(:io)    { double('io').as_null_object }
  let(:task)  { Webbynode::Commands::Tasks.new('add', 'after_push', 'rake', 'db:migrate', 'RAILS_ENV=production') }
  
  before(:each) do
    task.should_receive(:io).any_number_of_times.and_return(io)
  end
  
  describe "webbynode tasks folder and files" do
    context "when not available" do
      before(:each) do
        io.stub!(:directory?).with('.webbynode').and_return(false)
        io.stub!(:directory?).with('.webbynode/tasks').and_return(false)
      end
      
      it "should ensure the availability of the required webbynode files" do
        task.should_receive(:ensure_tasks_folder)
        task.execute
      end
      
      it "should create the webbynode tasks folder" do
        io.should_receive(:exec).with('mkdir .webbynode/tasks')
        task.execute
      end
      
      it "should create the 4 files required by the tasks command" do
        %w[before_create after_create before_push after_push].each do |file|
          io.should_receive(:file_exists?).with("./webbynode/tasks/#{file}").and_return(false)
          io.should_receive(:exec).with("touch ./webbynode/tasks/#{file}")
        end
        task.execute
      end
    end
    
    context "when available" do
      before(:each) do
        io.stub!(:directory?).with('.webbynode').and_return(true)
        io.stub!(:directory?).with('.webbynode/tasks').and_return(true)
      end
      
      it "should ensure the availability of the required webbynode files" do
        task.should_receive(:ensure_tasks_folder)
        task.execute
      end
      
      it "should create the webbynode folder" do
        io.should_not_receive(:exec).with('mkdir .webbynode')
        task.execute
      end
      
      it "should create the webbynode folder" do
        io.should_not_receive(:exec).with('mkdir .webbynode/tasks')
        task.execute
      end
      
      it "should create the 4 files required by the tasks command" do
        %w[before_create after_create before_push after_push].each do |file|
          io.should_receive(:file_exists?).with("./webbynode/tasks/#{file}").and_return(true)
          io.should_not_receive(:exec).with("touch ./webbynode/tasks/#{file}")
        end
        task.execute
      end
    end
  end
  
  it "should parse the params provided by the user" do
    task.should_receive(:parse_parameters)
    task.stub!(:send)
    task.execute
  end
  
  it "should have correctly parsed and stored the user input" do
    task.execute
    task.action.should  eql("add")
    task.type.should    eql("after_push")
    task.command.should eql("rake db:migrate RAILS_ENV=production")
  end
  
  it "should invoke the validate_parameters method" do
    task.should_receive(:validate_parameters)
    task.execute
  end
  
  it "should set the current path for the specified task interaction type" do
    task.should_receive(:set_session_file)
    task.execute
  end
  
  describe "selectable paths" do
    def selectable_helper(type)
      @task = @tasks_class.new(["add", type])
      @task.stub!(:validate_parameters)
      @task.stub!(:send)
      @task.should_receive(:io).any_number_of_times.and_return(io)
      @task.execute
    end
    
    before(:each) do
      @tasks_class = Webbynode::Commands::Tasks
    end
    
    it "should be the before_create path" do
      selectable_helper('before_create')
      @task.session_file.should eql(@tasks_class::BeforeCreateTasksFile)
    end
    
    it "should be the before_create path" do
      selectable_helper('after_create')
      @task.session_file.should eql(@tasks_class::AfterCreateTasksFile)
    end
    
    it "should be the before_create path" do
      selectable_helper('before_push')
      @task.session_file.should eql(@tasks_class::BeforePushTasksFile)
    end
    
    it "should be the before_create path" do
      selectable_helper('after_push')
      @task.session_file.should eql(@tasks_class::AfterPushTasksFile)
    end
  end
  
  context "should initialize the [add] or [remove] action, depending on user input" do
    it "should have a [add] and [remove] method availble" do
      task.private_methods.should include('add')
      task.private_methods.should include('remove')
    end
    
    it "should initialize the [add] method" do
      task.should_receive(:send).with('add')
      task.execute
    end
    
    it "should initialize the [remove] method" do
      task = Webbynode::Commands::Tasks.new(['remove', 'after_push', 'rake', 'db:migrate', 'RAILS_ENV=production'])
      task.should_receive(:send).with('remove')
      task.stub!(:read_tasks)
      task.execute
    end
  end
  
  describe "displaying tasks from a file" do
    let(:stask) { Webbynode::Commands::Tasks.new(['show', 'after_push']) }
    
    before(:each) do
      stask.should_receive(:io).any_number_of_times.and_return(io)
    end
    
    it "should invoke the [show] method" do
      stask.should_receive(:send).with('show')
      stask.execute
    end
    
    it "should read out the specified file" do
      stask.should_receive(:show_tasks)
      stask.execute
    end
    
    it "should display no tasks, since there are none initially" do
      io.should_receive(:log).with("These are the current tasks for \"After push\":")
      io.should_not_receive(:log)
      stask.execute
      stask.should have(0).session_tasks
    end
    
    it "should display 3 tasks: task0 task1 task2" do
      3.times {|num| stask.session_tasks << "task#{num}"}
      io.should_receive(:log).with("These are the current tasks for \"After push\":")
      stask.stub!(:read_tasks)
      io.should_not_receive(:log_and_exit)
      io.should_receive(:log).with("[0] task0")
      io.should_receive(:log).with("[1] task1")
      io.should_receive(:log).with("[2] task2")
      stask.execute
      stask.should have(3).session_tasks
    end
    
    it "should tell the user that there are no tasks if there aren't any" do
      stask.stub!(:read_tasks)
      io.should_receive(:log_and_exit).with("You haven't set up any tasks for \"After push\".")
      io.should_not_receive(:log).with("These are the current tasks for \"After push\".")
      stask.execute
    end
  end
  
  describe "adding tasks to a file" do
    before(:each) do
      task.should_receive(:io).any_number_of_times.and_return(io)
    end
    
    context "when successful" do
      it "should read the specified file" do
        task.should_receive(:read_tasks).with('.webbynode/tasks/after_push')
        task.stub!(:send)
        task.execute
      end
      
      it "should append the new task to the array" do
        task.should_receive(:append_task).with('rake db:migrate RAILS_ENV=production')
        task.execute
      end
      
      it "should have appended the new task to the array" do
        task.execute
        task.session_tasks.should include('rake db:migrate RAILS_ENV=production')
      end
      
      it "should write a new file with the updated task list" do
        task.should_receive(:write_tasks)
        task.execute
      end
      
      it "should display the updated list of tasks" do
        io.should_receive(:log).with("These are the current tasks for \"After push\":")
        io.should_receive(:log).with("[0] rake db:migrate RAILS_ENV=production")
        task.execute
      end
    end
  end
  
  describe "removing tasks from a file" do
    let(:rtask) { Webbynode::Commands::Tasks.new('remove', 'after_push', 1) }
    
    before(:each) do
      rtask.should_receive(:io).any_number_of_times.and_return(io)
    end
    
    context "when successful" do
      it "should initialize the [remove] method" do
        rtask.should_receive(:send).with('remove')
        rtask.execute
      end
      
      it "should remove the task from the list of available tasks" do
        rtask.should_receive(:delete_task).with(1)
        rtask.execute
      end
      
      it "should write the new tasks" do
        rtask.should_receive(:write_tasks)
        rtask.execute
      end
      
      it "should display the updated list of tasks" do
        3.times {|num| rtask.session_tasks << "task#{num}" }
        rtask.stub(:read_tasks)
        io.should_receive(:log).with("These are the current tasks for \"After push\":")
        io.should_receive(:log).with("[0] task0")
        io.should_not_receive(:log).with("[1] task1")
        io.should_receive(:log).with("[1] task2")
        rtask.execute
        rtask.session_tasks.should include("task0")
        rtask.session_tasks.should_not include("task1")
        rtask.session_tasks.should include("task2")
      end
    end
  end
end