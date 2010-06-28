# Require RSpec
require 'rubygems'
require 'spec'

# Load Webbynode Class
require File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'lib', 'webbynode')

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

World(Webbynode::IoStub)