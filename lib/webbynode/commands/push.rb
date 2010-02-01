module Webbynode::Commands
  class Push < Webbynode::Command
    
    requires_initialization!
    
    attr_accessor :app_name, :before_tasks, :after_tasks
    
    add_alias "deploy"
    
    summary "Sends all pending changes on the current application to your Webby"
    
    def initialize(*args)
      super
      @before_tasks = Webbynode::Commands::Tasks.new
      @after_tasks  = Webbynode::Commands::Tasks.new
    end
    
    def execute
      @app_name = pushand.parse_remote_app_name
      
      # Ensures there are Task Files to read from
      before_tasks.ensure_tasks_folder
      
      # Reads out the "before push" tasks file to see if there are any tasks that must be performed
      # It will perform the "before push" tasks if there are any available
      before_tasks.read_tasks(Webbynode::Commands::Tasks::BeforePushTasksFile)
      perform_before_tasks if before_tasks.has_tasks?
      
      # Logs a initialization message to the user
      # Pushes the application to Webbynode
      io.log "Pushing #{app_name}", :start
      io.exec("git push webbynode master", false)
      
      # Reads out the "after push" tasks file to see if there are any tasks that must be performed
      # It will perform the "after push" tasks if there are any available
      after_tasks.read_tasks(Webbynode::Commands::Tasks::AfterPushTasksFile)
      perform_after_tasks if after_tasks.has_tasks?
      
      io.log "Finished pushing #{app_name}", :finish
    end
    
    
    private
      
      # Performs the before push tasks locally
      def perform_before_tasks
        io.log("Performing Before Push Tasks..")
        before_tasks.session_tasks.each do |task|
          io.log("Performing Task: #{task}")
          io.exec(task)
        end
      end
      
      # Performs the after push tasks remotely from the application root
      def perform_after_tasks
        io.log("Performing After Push Tasks..")
        after_tasks.session_tasks.each do |task|
          io.log("Performing Task: #{task}")
          remote_executor.exec("cd #{pushand.parse_remote_app_name}; #{task}", true)
        end
      end
      
  end
end