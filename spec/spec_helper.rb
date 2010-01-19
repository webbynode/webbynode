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

# Reads out a file from the fixtures directory
def read_fixture(file)
  File.read(File.join(File.dirname(__FILE__), "fixtures", file))
end

module Kernel
  def ask(*params)
    raise "Unexpected ask with: #{params.inspect}"
  end
end