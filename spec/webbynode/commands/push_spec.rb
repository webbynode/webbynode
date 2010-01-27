# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Push do

  let(:push) { Webbynode::Commands::Push.new }
  let(:io) { double('Io').as_null_object }
  let(:re) { double('RemoteExecutor').as_null_object }
  let(:pushand) { double('PushAnd').as_null_object }

  before(:each) do
    push.should_receive(:io).any_number_of_times.and_return(io)
    push.should_receive(:remote_executor).any_number_of_times.and_return(re)
    push.should_receive(:pushand).any_number_of_times.and_return(pushand)
    push.before_tasks.stub!(:read_tasks)
    push.after_tasks.stub!(:read_tasks)
  end
  
  context "when the user runs the command" do
    it "should display a message that the application is being pushed to the webby" do
      io.should_receive(:log).with("Pushing your application to Webbynode!")
      push.stub!(:exec)
      push.execute
    end
    
    it "should push the application to the webby" do
      io.should_receive(:exec).with("git push webbynode master")
      push.execute
    end
    
    describe "Tasks" do
      it "should have 2 before_tasks present" do
        push.execute
        2.times { push.before_tasks.session_tasks << "foo" }
        push.before_tasks.session_tasks.should have(2).session_tasks
        push.before_tasks.should be_an_instance_of(Webbynode::Commands::Tasks)
      end
    
      it "should have 2 after_tasks present" do
        push.execute
        2.times { push.after_tasks.session_tasks << "foo" }
        push.after_tasks.session_tasks.should have(2).session_tasks
        push.after_tasks.should be_an_instance_of(Webbynode::Commands::Tasks)
      end
      
      it "should read the tasks files to see whether there are tasks available" do
        push.before_tasks.should_receive(:read_tasks).with(Webbynode::Commands::Tasks::BeforePushTasksFile)
        push.after_tasks.should_receive(:read_tasks).with(Webbynode::Commands::Tasks::AfterPushTasksFile)
        push.execute
      end
      
      it "should check if there are any before_tasks or after_tasks" do
        push.before_tasks.should_receive(:has_tasks?)
        push.after_tasks.should_receive(:has_tasks?)
        push.execute
      end
      
      it "should ensure that there are at least blank files available to read from" do
        push.before_tasks.should_receive(:ensure_tasks_folder)
        push.execute
      end
      
      it "should not initialize the before_tasks if there aren't any tasks to perform" do
        push.before_tasks.should_receive(:has_tasks?).and_return(false)
        push.should_not_receive(:perform_before_tasks)
        push.execute
      end
      
      it "should not initialize the after_tasks if there aren't any tasks to perform" do
        push.after_tasks.should_receive(:has_tasks?).and_return(false)
        push.should_not_receive(:perform_after_tasks)
        push.execute
      end
    end
    
    describe "before_push tasks" do
      context "when there are one or more tasks available" do
        before(:each) do
          push.before_tasks.stub!(:has_tasks?).and_return(true)
        end
        
        it "should perform these tasks in order" do
          push.should_receive(:perform_before_tasks)
          push.execute
        end
      end
    end
    
    describe "after_push tasks" do
      context "when there are one or more tasks available" do
        before(:each) do
          push.after_tasks.stub!(:has_tasks?).and_return(true)
        end
        
        it "should perform these tasks in order" do
          push.should_receive(:perform_after_tasks)
          push.execute
        end
      end
    end
    
    describe "#perform_before_tasks" do
      before(:each) do
        push.before_tasks.stub!(:has_tasks?).and_return(true)
        io.stub!(:exec).with("git push webbynode master")
      end
      
      it "should provide feedback to the user that it's going to perform the tasks" do
        io.should_receive(:log).with("Performing Before Push Tasks..")
        push.execute
      end
      
      it "should loop through each of the tasks, perform them and provide feedback" do
        3.times { |n| push.before_tasks.session_tasks << "Task #{n}" }
        3.times { |n| io.should_receive(:exec).exactly(:once).with("Task #{n}") }
        3.times { |n| io.should_receive(:log).exactly(:once).with("Performing Task: Task #{n}")}
        push.execute
      end
    end
    
    describe "#perform_after_tasks" do
      before(:each) do
        push.after_tasks.stub!(:has_tasks?).and_return(true)
        io.stub!(:exec).with("git push webbynode master")
      end
      
      it "should provide feedback to the user that it's going to perform the tasks" do
        io.should_receive(:log).with("Performing After Push Tasks..")
        push.execute
      end
      
      it "should loop through each of the tasks, perform them and provide feedback" do
        3.times { |n| push.after_tasks.session_tasks << "Task #{n}" }
        3.times { |n| re.should_receive(:exec).exactly(:once).with("cd test.webbynode.com; Task #{n}", true) }
        3.times { |n| io.should_receive(:log).exactly(:once).with("Performing Task: Task #{n}")}
        pushand.should_receive(:parse_remote_app_name).exactly(3).times.and_return("test.webbynode.com")
        push.execute
      end
    end
    
  end
end