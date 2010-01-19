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
    def parse_command
      log_and_exit read_template('help') if @input.empty?
      @command  = @input.shift
      @options  = @input
    end
    
    # Executes the parsed command
    def execute
      parse_command
      run_command(command)
    end
    
    # Runs the command unless it's nil or doesn't exist
    # If it fails, it will display the help screen
    def run_command(command)
      if !command.nil? and respond_to?(command)
        send(command)
      else
        log_and_exit read_template('help')
      end
    end
    
  end
end