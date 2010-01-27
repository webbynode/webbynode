module Webbynode::Commands
  class Tasks < Webbynode::Command
    requires_initialization!
    parameter :params, Array, "Command to execute"
    
    attr_accessor :action, :type, :command, :session_file, :session_tasks
    
    def params
      param(:params)
    end
    
    # Constants
    # Paths to the webbynode task files
    TasksPath               = ".webbynode/tasks"
    BeforePushTasksFile     = ".webbynode/tasks/before_push"
    AfterPushTasksFile      = ".webbynode/tasks/after_push"
    
    def initialize(*args)
      super
      @session_tasks = Array.new
    end
    
    def execute
      
      # Ensures that the tasks folder (.webbynode/tasks) is present
      # Will create the task files if they are not present
      ensure_tasks_folder
      
      # Should validate the parameters
      validate_parameters
      
      # Should parse the parameters
      parse_parameters
      
      # Sets the current path, extracted from @type
      set_session_file
      
      # Reads out the currently set tasks
      read_tasks(session_file)
      
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
      
      # Appends a task to the session_tasks method.
      def append_task(task)
        @session_tasks << task
      end
      
      # Overwrites the existing file with the new tasks list
      # This will always be done from the session_tasks.
      def write_tasks
        io.open_file(session_file, "w") do |file|
          session_tasks.each do |task|
            file.write "#{task}\n"
          end
        end
      end
      
      # Removes a task based on the number(index) provided.
      # example: delete_task(2)
      # This will remove whatever task is 3rd in the session_tasks array.
      def delete_task(i)
        filtered_tasks = []
        session_tasks.each_with_index do |task, index|
          filtered_tasks << task unless index.eql?(i)
        end
        @session_tasks = filtered_tasks
      end
      
      # Reads out each task (in order) either from the session_tasks method
      # or straight from the physical file on the filesystem and outputs it directly
      # in the console to the user for feedback.
      def show_tasks(from_file = false)
        read_tasks(session_file, true) if from_file
        if session_tasks.empty?
          io.log_and_exit "You haven't set up any tasks for \"#{type.gsub('_',' ').capitalize}\"."
        end
        io.log "These are the current tasks for \"#{type.gsub('_',' ').capitalize}\":"
        session_tasks.each_with_index do |task, index|
          io.log "[#{index}] #{task}"
        end
      end
      
      # TODO
      # Felipe's Validation Thingy
      def validate_parameters
      end
      
      # Determines the selected file that will be used for the current session.
      # This will be stored inside the session_file method.
      def set_session_file
        case @type
        when 'before_push'    then sf = BeforePushTasksFile
        when 'after_push'     then sf = AfterPushTasksFile
        end
        @session_file = sf
      end
      
      # Reads the tasks straight from the specified file and stores them inside (in order)
      # the session_tasks method.
      def read_tasks(file)
        tasks = []
        @session_tasks = []
        io.read_file(file).each_line {|line| tasks << line.gsub(/\n/,'') unless line.blank? }
        tasks.each_with_index do |task, index|
          @session_tasks << "#{task}"
        end
      end
      
      # Ensures the presence of the .webbynode/tasks folder
      # Will create the necessary task files when they are not available
      def ensure_tasks_folder
        io.exec('mkdir .webbynode/tasks') unless io.directory?(".webbynode/tasks")
        %w[before_push after_push].each do |file|
          io.exec("touch .webbynode/tasks/#{file}") unless io.file_exists?(".webbynode/tasks/#{file}")
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