require 'spec_helper'

describe Webbynode::Commands::Credentials do
  let(:remote_executor) { double(:remote_executor) }
  let(:pushand) { double(:pushand).as_null_object }
  let(:io) { double(:io).as_null_object }

  let(:attributes) { [] }

  before {
    Webbynode::Command.stub(:check_for_updates)
    io.stub(:log)
  }

  subject do
    Webbynode::Commands::Config.new(*attributes).tap do |cmd|
      cmd.stub(remote_executor: remote_executor)
      cmd.stub(pushand: pushand)
      cmd.stub(io: io)
    end
  end

  context "with list command" do
    it "lists all configs" do
      subject.stub(parse_vars: {"A" => "VAL_A", "B" => "VAL_B"})
      subject.execute

      io.should have_received(:log).with("A=VAL_A")
      io.should have_received(:log).with("B=VAL_B")
    end
  end

  context "with set command" do
    before do
      subject.stub(:set_var)
      subject.stub(:list_command)
      subject.execute
    end

    context "with all attributes" do
      let(:attributes) { ["set", "RAILS_ENV", "production"] }

      it "sets the config" do
        subject.should have_received(:set_var).with("RAILS_ENV", "production")
      end
    end

    context "with missing value" do
      let(:attributes) { ["set", "RAILS_ENV"] }

      it "shows an error" do
        io.should have_received(:log).with("Missing value")
      end
    end

    context "with missing name and value" do
      let(:attributes) { ["set"] }

      it "shows an error" do
        io.should have_received(:log).with("Missing name and value")
      end
    end
  end

  context "with remove command" do
    before do
      subject.stub(:unset_var)
      subject.stub(:list_command)
      subject.execute
    end

    context "with all attributes" do
      let(:attributes) { ["remove", "RAILS_ENV"] }

      it "sets the config" do
        subject.should have_received(:unset_var).with("RAILS_ENV")
      end
    end

    context "with missing name" do
      let(:attributes) { ["remove"] }

      it "shows an error" do
        io.should have_received(:log).with("Missing name")
      end
    end
  end

  describe "#set_var" do
    before do
      subject.stub(:list_command)
      remote_executor.stub(:exec)

      subject.path = "/app_name"
      subject.set_var("NAME", "VALUE")
    end

    it "runs the command to set the variable" do
      remote_executor.should have_received(:exec).with("dir=\"/var/webbynode/env/app_name\"\nmkdir -p $dir\necho \"VALUE\" > $dir/NAME\n")
    end
  end

  describe "#unset_var" do
    before do
      subject.stub(:list_command)
      remote_executor.stub(:exec)

      subject.path = "/app_name"
      subject.unset_var("NAME")
    end

    it "runs the command to set the variable" do
      remote_executor.should have_received(:exec).with("dir=\"/var/webbynode/env/app_name\"\nmkdir -p $dir\nrm $dir/NAME\n")
    end
  end

  describe "#parse_vars" do
    before do
      subject.stub(list_vars: "A=VAL_A\nB=VAL_B")
    end

    it "returns a hash with the values" do
      expect(subject.parse_vars("path")).to eql({"A" => "VAL_A", "B" => "VAL_B"})
    end
  end

  describe "#list_vars" do
    before do
      remote_executor.stub(:exec)
      subject.list_vars("app_name")
    end

    it "runs the command to set the variable" do
      remote_executor.should have_received(:exec).with("dir=\"/var/webbynode/envapp_name\"\n\nif [ ! -d $dir ]; then\n  exit 0\nfi\n\nif ! ls -A $dir/* > /dev/null 2>&1; then\n  exit 0\nfi\n\ncd $dir\n\nfor f in *; do\n   if [ ! -d $f ]; then\n      contents=`cat $f`\n      [ -z $contents ] || echo \"$f=$contents\"\n   fi\ndone\n")
    end
  end
end
