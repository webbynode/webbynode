# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Webbynode::Taps do
  let(:io)  { double("io").as_null_object }
  let(:re)  { double("re").as_null_object }
  
  subject do
    Webbynode::Taps.new("dbname", "password", io, re)
  end
  
  its(:database)          { should == "dbname" }
  its(:database_password) { should == "password" }
  its(:io)                { should == io }
  its(:remote_executor)   { should == re }
  
  describe '#start' do
    it "starts a tap server" do
      io.should_receive(:random_password).and_return("some_username")
      io.should_receive(:random_password).and_return("some_password")

      re.should_receive(:exec).with("bash -c 'nohup taps server mysql://dbname:password@localhost/dbname some_username some_password > /dev/null 2>&1 &\necho $!'").and_return("12145\n")
      
      subject.start
      subject.pid.should == "12145"
    end
    
    it "reports a failure in case the result is not a PID" do
      re.should_receive(:exec).and_return("Bad credentials given for http://UIK7MgBLx3:[hidden]@174.122.137.2:5000")
      
      lambda { subject.start }.should raise_error
    end
  end
  
  describe '#pull' do
    context "when started" do
      before(:each) do 
        subject.stub(:user).and_return("user")
        subject.stub(:password).and_return("password")
      end
      
      it "executes the pull command locally" do
        io.should_receive(:execute).with("taps pull mysql://local_user:local_password@localhost/local_db http://user:password@1.1.2.2:5000").and_return(0)

        subject.pull :user => "local_user", 
          :password        => "local_password",
          :database        => "local_db",
          :remote_ip       => "1.1.2.2"
      end

      
      it "raises an error if pull fails" do
        io.should_receive(:execute).and_return(1)

        lambda { subject.pull({}) }.should raise_error
      end
    end

    context "when not started" do
      it "raises an error" do
        lambda { subject.pull }.should raise_error
      end
    end
  end
  
  describe '#finish' do
    before(:each) do
      re.should_receive(:exec).with(/taps server/).and_return("1234\n")
      subject.start
    end

    context "when successful" do
      it "kills taps remotely" do
        re.should_receive(:exec).with("kill -9 1234").and_return(0)
        subject.finish
      end
    end
    
    context "when unsuccessful" do
      it "raises an error" do
        re.should_receive(:exec).with("kill -9 1234").and_return(1)
        lambda { subject.finish }.should raise_error
      end
    end
  end
end
