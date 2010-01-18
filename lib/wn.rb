$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pp'
require File.join(File.dirname(__FILE__), 'wn', 'helpers')
require File.join(File.dirname(__FILE__), 'wn', 'commands')

module Wn
  VERSION = '0.1.2'
  
  class App
    attr_accessor :input, :command, :options
    
    include Wn::Helpers
    include Wn::Commands
    
    # Initializes the Webbynode App
    def initialize(*input)
      @input = input.flatten
    end
    
    # Parses user input (commands)
    # Initial param is the command
    # Other params are arguments
    def parse
      log_and_exit read_template('help') if @input.empty?
      @command  = @input.shift
      @options  = @input
    end
    
    # Executes the parsed command
    def execute
      parse
      send(command)
    end
    
    def parse_configuration(file)
      config = {}
      current = nil
      
      File.open(file).each_line do |line|
        case line
        when /^\[(\w+)(?: "(.+)")*\]/
          key, subkey = $1, $2
          current = (config[key] ||= {})
          current = (current[subkey] ||= {}) if subkey
        else
          key, value = line.strip.split(' = ')
          current[key] = value
        end
      end

      config
    end
    
    def remote_ip
      @config ||= parse_configuration(".git/config")
      @remote_ip ||= $2  if @config["remote"]["webbynode"]["url"] =~ /^(\w+)@(.+):(\w+)$/ 
    end
  end
end