# Load Spec Helper
require File.join(File.expand_path(File.dirname(__FILE__)), '../..', 'spec_helper')

describe Webbynode::Commands::Apps do
  let(:re)      { double("RemoteExecutor").as_null_object }

  subject do
    Webbynode::Commands::Apps.new.tap do |cmd|
      cmd.stub(:remote_executor).and_return(re)
    end
  end

  it "executes list_apps remotely" do
    Webbynode::ApiClient.stub(:system => "manager")
    re.should_receive(:exec).with("list_apps", true)
    subject.execute
  end
end
