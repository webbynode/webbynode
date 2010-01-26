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
      
      # Initializes either [add], [remove] or [show] depending on user input
      send(action)
      
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
      
      # Gets invoked if the user specified [show] for @action
      def show
        show_tasks  
      end
      
      # Appends a task to the selected_tasks method.
      def append_task(task)
        @selected_tasks << task
      end
      
      # Overwrites the existing file with the new tasks list
      # This will always be done from the selected_tasks.
      def write_tasks
        io.open_file(selected_file, "w") do |file|
          selected_tasks.each_with_index do |task, index|
            file << task if index.eql?(0)
            file << "\n#{task}" unless index.eql?(0)
          end
        end
      end
      
      # Removes a task based on the number(index) provided.
      # delete_task(2)
      # This will remove whatever task is 3rd in the selected_tasks array.
      def delete_task(i)
        filtered_tasks = []
        selected_tasks.each_with_index do |task, index|
          filtered_tasks << task unless index.eql?(i)
        end
        @selected_tasks = filtered_tasks
      end
      
      # Reads out each task (in order) either from the selected_tasks method
      # or straight from the physical file on the filesystem and outputs it directly
      # in the console to the user for feedback.
      def show_tasks(from_file = false)
        read_tasks(selected_file, true) if from_file
        puts "These are the current tasks for \"#{type.gsub('_',' ').capitalize}\":"
        selected_tasks.each_with_index do |task, index|
          puts "[#{index}] #{task}"
        end
      end
      
      # TODO
      # Felipe's Validation Thingy
      def validate_parameters
      end
      
      # Determines the selected file that will be used for the current session.
      # This will be stored inside the selected_file method.
      def set_selected_file
        case @type
        when 'before_create'  then cp = BeforeCreateTasksFile
        when 'after_create'   then cp = AfterCreateTasksFile
        when 'before_push'    then cp = BeforePushTasksFile
        when 'after_push'     then cp = AfterPushTasksFile
        end
        @selected_file = cp
      end
      
      # Reads the tasks straight from the specified file and stores them inside (in order)
      # the selected_tasks method.
      def read_tasks(file)
        tasks = []
        @selected_tasks = []
        io.read_file(file).each_line {|line| tasks << line.gsub(/\n/,'') unless line.blank? }
        tasks.each_with_index do |task, index|
          @selected_tasks << "[#{index}] #{task}"
        end
      end
      
      # Parses the parameters and stores the params inside 3 different methods
      # [action]  represents: [add/remove/show]
      # [type]    represents: [before/after_create before/after_push]
      # [command] represents: The remote command that should get executed
      def parse_parameters
        params.flatten!
        @action   = params.shift
        @type     = params.shift
        @command  = params.join(" ")
      end
        
  end
end