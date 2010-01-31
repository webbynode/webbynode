$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'net/ssh'
require 'highline/import'
require 'pp'

require File.join(File.dirname(__FILE__), 'webbynode', 'helpers')
require File.join(File.dirname(__FILE__), 'webbynode', 'io')
require File.join(File.dirname(__FILE__), 'webbynode', 'git')
require File.join(File.dirname(__FILE__), 'webbynode', 'ssh')
require File.join(File.dirname(__FILE__), 'webbynode', 'server')
require File.join(File.dirname(__FILE__), 'webbynode', 'push_and')
require File.join(File.dirname(__FILE__), 'webbynode', 'command')
require File.join(File.dirname(__FILE__), 'webbynode', 'option')
require File.join(File.dirname(__FILE__), 'webbynode', 'parameter')
require File.join(File.dirname(__FILE__), 'webbynode', 'api_client')
require File.join(File.dirname(__FILE__), 'webbynode', 'remote_executor')
require File.join(File.dirname(__FILE__), 'webbynode', 'notify')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'init')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'push')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_key')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'delete')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'remote')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'tasks')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'start')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'stop')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'restart')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'alias')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'help')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'version')

require File.join(File.dirname(__FILE__), 'webbynode', 'application')

module Webbynode
  VERSION = '0.1.2'
end

class Array
  def to_phrase(last_join="and")
    return "" if empty?

    array = self.clone
    last = array.pop

    return last if array.empty?

    "#{array.join(", ")} #{last_join} #{last}"
  end
end