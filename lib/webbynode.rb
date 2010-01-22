$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'net/ssh'
require 'highline/import'
require 'pp'

require File.join(File.dirname(__FILE__), 'webbynode', 'io')
require File.join(File.dirname(__FILE__), 'webbynode', 'git')
require File.join(File.dirname(__FILE__), 'webbynode', 'ssh')
require File.join(File.dirname(__FILE__), 'webbynode', 'server')
require File.join(File.dirname(__FILE__), 'webbynode', 'push_and')
require File.join(File.dirname(__FILE__), 'webbynode', 'remote_executor')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'init')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'add_key')
require File.join(File.dirname(__FILE__), 'webbynode', 'commands', 'remote')

module Webbynode
  VERSION = '0.1.2'
  
  class AppError < StandardError; end
  
  class Application
    attr_reader :command, :command_class, :params, :options
    
    def initialize(*args)
      @command = args.shift
      @params = []
      @options = {}
      parse_args(args)
    end
    
    def parse_command
      @command_class = Webbynode::Commands.const_get(command_class_name)
    rescue NameError
      puts "Command \"#{command}\" doesn't exist"
    end
    
    def command_class_name
      command.split("_").inject([]) { |arr, item| arr << item.capitalize }.join("")
    end
    
    def execute
      parse_command
      command_class.run params, options
    end
    
    def parse_args(args)
      while (opt = args.shift)
        if opt =~ /^--(\w+)(=("[^"]+"|[\w]+))*/
          name  = $1
          value = $3 ? $3.gsub(/"/, "") : true
          @options[name.to_sym] = value
        else
          @params << opt
        end
      end
    end
  end
end