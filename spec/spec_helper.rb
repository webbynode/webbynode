# Require RSpec
require 'rubygems'
require 'spec'
require 'pp'
begin
  require 'fakeweb'
rescue LoadError
  puts "Missing gem fakeweb, required for testing."
  puts "Run:"
  puts "  sudo gem install fakeweb"
  exit
end

# Load Webbynode Class
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'webbynode')

# Set Testing Environment
$testing = true
FakeWeb.allow_net_connect = false

# Helper Methods
module Webbynode::IoStub
  def stdout
    $stdout.rewind
    $stdout.read
  end

  def debug(s)
    @orig_stdout.puts s
  end
  
  def d(x); $stderr.puts x; end
  def ppd(x); $stderr.puts x.pretty_inspect; end
end

# Reads out a file from the fixtures directory
def read_fixture(file)
  File.read(File.join(File.dirname(__FILE__), "fixtures", file))
end

module Kernel
  def ask(*params)
    raise "Unexpected ask with: #{params.inspect}"
  end
end

Spec::Runner.configure do |config|
  config.include Webbynode::IoStub

  config.before(:each) do
    @orig_stdout = $stdout
    $stdout = StringIO.new
  end
  
  config.after(:each) do
    $stdout = @orig_stdout
  end
end