module Webbynode::Commands
  class Push < Webbynode::Command
    include Webbynode::Updater
    
    requires_initialization!
    
    attr_accessor :app_name, :before_tasks, :after_tasks
    
    add_alias "deploy"
    
    summary "Sends pending changes on the current application to your Webby"
    option :dirty, "Allows pushing even if the current application has git changes pending"
    option :'recreate-vhost', "Recreates the vhost file, overwriting any manual changes"
    
    def initialize(*args)
      super
      @before_tasks = Webbynode::Commands::Tasks.new
      @after_tasks  = Webbynode::Commands::Tasks.new
    end
    
    def execute
      unless option(:dirty)
        raise CommandError, 
          "Cannot push because you have pending changes. Do a git commit or add changes to .gitignore." unless git.clean?
      end
      
      @app_name = pushand.parse_remote_app_name
      
      # Ensures there are Task Files to read from
      before_tasks.ensure_tasks_folder
      
      # Reads out the "before push" tasks file to see if there are any tasks that must be performed
      # It will perform the "before push" tasks if there are any available
      before_tasks.read_tasks(Webbynode::Commands::Tasks::BeforePushTasksFile)
      perform_before_tasks if before_tasks.has_tasks?
      
      handle_semaphore
      
      # Logs a initialization message to the user
      io.log "Pushing #{app_name.color(:cyan)}", :start
      
      # Checks for server-side updates
      if check_for_updates
        io.log "Note: Rapp Engine updated".color(:yellow)
        io.log ""
      end
      
      # Pushes the application to Webbynode
      io.exec("git push webbynode +HEAD:master", false)
      
      # Reads out the "after push" tasks file to see if there are any tasks that must be performed
      # It will perform the "after push" tasks if there are any available
      after_tasks.read_tasks(Webbynode::Commands::Tasks::AfterPushTasksFile)
      perform_after_tasks if after_tasks.has_tasks?
      
      io.log "Finished pushing #{app_name.color(:cyan)}", :finish
    end
    
    def handle_semaphore
      return unless option(:'recreate-vhost')
      remote_executor.exec "mkdir -p /var/webbynode/semaphores && touch /var/webbynode/semaphores/recreate_#{app_name}"
    end
    
    private
      
      # Performs the before push tasks locally
      def perform_before_tasks
        io.log "Performing #{"Before Push".color(:yellow)} Tasks...", :action
        before_tasks.session_tasks.each do |task|
          io.log "  Performing Task: #{task.color(:cyan)}", :action
          io.exec(task)
        end
      end
      
      # Performs the after push tasks remotely from the application root
      def perform_after_tasks
        io.log "Performing #{"After Push".color(:yellow)} Tasks...", :action
        after_tasks.session_tasks.each do |task|
          io.log "  Performing Task: #{task.color(:cyan)}", :action
          remote_executor.exec("cd #{pushand.parse_remote_app_name}; #{task}", true)
        end
      end
      
  end
end