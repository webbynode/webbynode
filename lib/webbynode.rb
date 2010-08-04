$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'domainatrix'
require 'net/ssh'
require 'highline/import'
require 'pp'

require File.join(File.dirname(__FILE__), 'webbynode', 'io')
require File.join(File.dirname(__FILE__), 'webbynode', 'git')
require File.join(File.dirname(__FILE__), 'webbynode', 'ssh')
require File.join(File.dirname(__FILE__), 'webbynode', 'server')
require File.join(File.dirname(__FILE__), 'webbynode', 'push_and')
require File.join(File.dirname(__FILE__), 'webbynode', 'gemfile')
require File.join(File.dirname(__FILE__), 'webbynode', 'command')
require File.join(File.dirname(__FILE__), 'webbynode', 'option')
require File.join(File.dirname(__FILE__), 'webbynode', 'parameter')
require File.join(File.dirname(__FILE__), 'webbynode', 'api_client')
require File.join(File.dirname(__FILE__), 'webbynode', 'remote_executor')
require File.join(File.dirname(__FILE__), 'webbynode', 'notify')
require File.join(File.dirname(__FILE__), 'webbynode', 'updater')
require File.join(File.dirname(__FILE__), 'webbynode', 'properties')
require File.join(File.dirname(__FILE__), 'webbynode', 'attribute_accessors')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'engine')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'rails')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'rails3')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'rack')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'django')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'php')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'all')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'apps')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'addons')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'init')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'push')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'config')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_key')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_backup')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'change_dns')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'delete')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'remote')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'tasks')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'start')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'stop')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'restart')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'alias')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'help')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'open')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'webbies')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'version')
require File.join(File.dirname(__FILE__), 'webbynode', 'application')

module Webbynode
  VERSION = '1.0.0'
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