module Webbynode::Commands
  class Tasks < Webbynode::Command
    
    requires_initialization!
    
    attr_accessor :action, :type, :command, :selected_file, :selected_tasks
    
    # Constants
    # Paths to the webbynode task files
    TasksPath               = ".webbynode/tasks"
    BeforeCreateTasksFile   = ".webbynode/tasks/before_create"
    AfterCreateTasksFile    = ".webbynode/tasks/after_create"
    BeforePushTasksFile     = ".webbynode/tasks/before_push"
    AfterPushTasksFile      = ".webbynode/tasks/after_push"
    
    def initialize(*args)
      super
      @selected_tasks = Array.new
    end
    
    def execute
      
      # Should validate the parameters
      validate_parameters
      
      # Should parse the parameters
      parse_parameters
      
      # Sets the current path, extracted from @type
      set_selected_file
      
      # Reads out the currently set tasks
      read_tasks(selected_file)
      
      # Initializes either [add] or [remove] depending on user input
      send(action)
      
    end
  
    def read_tasks(file, index = false)
      tasks = []
      @selected_tasks = []
      io.read_file(file).each_line {|line| tasks << line.gsub(/\n/,'') unless line.blank? }
      tasks.each_with_index do |task, index|
        if index
          @selected_tasks << "[#{index}] #{task}"
        else
          @selected_tasks << task
        end
      end
    end
  
    private
      
      # Gets invoked if the user specified [add] for @action
      def add
        append_task(command)
        write_tasks
        show_tasks
      end

      # Gets invoked if the user specified [remove] for @action    
      def remove
        delete_task(command.to_i)
        write_tasks
        show_tasks
      end
      
      def append_task(cmd)
        @selected_tasks << cmd
      end
      
      def write_tasks
        io.open_file(selected_file, "w") do |file|
          selected_tasks.each_with_index do |task, index|
            file << task if index.eql?(0)
            file << "\n#{task}" unless index.eql?(0)
          end
        end
      end
      
      def delete_task(i)
        filtered_tasks = []
        selected_tasks.each_with_index do |task, index|
          filtered_tasks << task unless index.eql?(i)
        end
        @selected_tasks = filtered_tasks
      end
      
      def show_tasks(from_file = false)
        read_tasks(selected_file, true) if from_file
        puts "These are the current tasks for \"#{type.gsub('_',' ').capitalize}\":"
        selected_tasks.each_with_index do |task, index|
          puts "[#{index}] #{task}"
        end
      end
      
      def validate_parameters
      end
      
      def set_selected_file
        case @type
        when 'before_create'  then cp = BeforeCreateTasksFile
        when 'after_create'   then cp = AfterCreateTasksFile
        when 'before_push'    then cp = BeforePushTasksFile
        when 'after_push'     then cp = AfterPushTasksFile
        end
        @selected_file = cp
      end
    
      def parse_parameters
        params.flatten!
        @action   = params.shift
        @type     = params.shift
        @command  = params.join(" ")
      end
        
  end
end