# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::AddBackup do
  def tie_dependencies(cmd)
    cmd.should_receive(:io).any_number_of_times.and_return(io)
    cmd.should_receive(:remote_executor).any_number_of_times.and_return(re)
    cmd.should_receive(:pushand).any_number_of_times.and_return(pushand)
    cmd
  end
  
  let(:io)  { double("io").as_null_object }
  let(:re)  { double("remote_executor").as_null_object }
  let(:pushand)  { double("pushand").as_null_object }
  let(:cmd) { 
    cmd = Webbynode::Commands::AddBackup.new
    tie_dependencies(cmd)
  }
  
  it "should allow user to specify a retention period, in days" do
    # io.should_receive(:app_name).and_return("app")
    pushand.should_receive(:parse_remote_app_name).and_return("app")
    io.should_receive(:general_settings).any_number_of_times.and_return({ "aws_key" => "abc", "aws_secret" => "def" })
    re.should_receive(:exec).with("config_app_backup").with(%Q(config_app_backup app "abc" "def" 10), true)

    cmd = tie_dependencies(Webbynode::Commands::AddBackup.new("--retain=10"))
    cmd.run
  end
  
  it "should ask user's aws key and secret, if missing from ~/.weebynode" do
    io.should_receive(:general_settings).any_number_of_times.and_return({})

    io.should_receive(:add_general_setting).with("aws_key", "aws_key")
    io.should_receive(:add_general_setting).with("aws_secret", "aws_secret")
    
    cmd.should_receive(:ask).with("AWS secret: ").and_return("aws_secret")
    cmd.should_receive(:ask).with("AWS key: ").and_return("aws_key")
    cmd.run
  end
  
  it "should abort the configuration if user provides a blank AWS key" do
    io.should_receive(:general_settings).any_number_of_times.and_return({})

    io.should_receive(:add_general_setting).never
    io.should_receive(:add_general_setting).never
    
    cmd.should_receive(:ask).with("AWS secret: ").never
    cmd.should_receive(:ask).with("AWS key: ").and_return("")
    cmd.run
    
    stdout.should =~ /Aborted./
  end
  
  it "should not ask for key/secret if already present" do
    io.should_receive(:general_settings).any_number_of_times.and_return({ "aws_key" => "abc", "aws_secret" => "def" })
    
    cmd.should_receive(:ask).with("AWS secret: ").never
    cmd.should_receive(:ask).with("AWS key: ").never
    cmd.run
  end
  
  it "should execute the config_app_backup utility on the server" do
    # io.should_receive(:app_name).and_return("app_name")
    pushand.should_receive(:parse_remote_app_name).and_return("app_name")
    io.should_receive(:general_settings).any_number_of_times.and_return({ "aws_key" => "awskey", "aws_secret" => "awsecret" })
    re.should_receive(:exec).with("config_app_backup").with(%Q(config_app_backup app_name "awskey" "awsecret"), true)

    cmd.run
  end
end