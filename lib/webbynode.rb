$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'httparty'
require 'domainatrix'
require 'net/ssh'
require 'highline/import'
require 'readline'
require 'rainbow'

begin
  require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /mswin/
rescue LoadError
  puts "Hint: if you want to make your output better in windows, install the win32console gem:"
  puts "      gem install win32console"
  puts ""
end

require File.join(File.dirname(__FILE__), 'webbynode', 'io')
require File.join(File.dirname(__FILE__), 'webbynode', 'git')
require File.join(File.dirname(__FILE__), 'webbynode', 'ssh')
require File.join(File.dirname(__FILE__), 'webbynode', 'server')
require File.join(File.dirname(__FILE__), 'webbynode', 'push_and')
require File.join(File.dirname(__FILE__), 'webbynode', 'gemfile')
require File.join(File.dirname(__FILE__), 'webbynode', 'command')
require File.join(File.dirname(__FILE__), 'webbynode', 'action_command')
require File.join(File.dirname(__FILE__), 'webbynode', 'option')
require File.join(File.dirname(__FILE__), 'webbynode', 'parameter')
require File.join(File.dirname(__FILE__), 'webbynode', 'api_client')
require File.join(File.dirname(__FILE__), 'webbynode', 'remote_executor')
require File.join(File.dirname(__FILE__), 'webbynode', 'notify')
require File.join(File.dirname(__FILE__), 'webbynode', 'updater')
require File.join(File.dirname(__FILE__), 'webbynode', 'trial')
require File.join(File.dirname(__FILE__), 'webbynode', 'taps')
require File.join(File.dirname(__FILE__), 'webbynode', 'properties')
require File.join(File.dirname(__FILE__), 'webbynode', 'attribute_accessors')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'engine')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'rails')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'rails3')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'rack')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'django')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'php')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'nodejs')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'wsgi')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'html')
require File.join(File.dirname(__FILE__), 'webbynode', 'engines', 'all')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'accounts')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'apps')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'addons')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'init')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'push')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'config')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_key')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_backup')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'change_dns')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'delete')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'dns_aliases')
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
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'user')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'settings')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'authorize_root')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'console')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'logs')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'guides')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'ssh')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'database')
require File.join(File.dirname(__FILE__), 'webbynode', 'application')

module Webbynode
  VERSION = '1.0.5'
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

unless Object.respond_to?(:blank?)
  class Object
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end