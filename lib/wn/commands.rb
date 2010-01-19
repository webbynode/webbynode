module Wn
  module Commands
    
    # Deploys the application to Webbynode
    def push
      unless dir_exists(".git")
        log "Not an application or missing initialization. Use 'webbynode init'."
        return
      end

      log "Publishing #{app_name} to Webbynode..."
      run "git push webbynode master"
    end
    
    # Executes a command on the server
    # Expects the first option to be the task
    # Command will be executed from the ~/remote_app_name directory, which is the application root
    def remote
      log_and_exit read_template('help') if options.empty?
      
      # Finds the remote ip and stores it in "remote_ip"
      parse_remote_ip
      
      # Finds the remote ip and stores it in "remote_app_name"
      parse_remote_app_name
      
      # Attempts to run the specified command
      run_remote_command(options[0])
    end
    
    # Initializes the Repository and adds Webbynode to the remote
    # Adds a populated the .gitignore file
    # Creates the .pushand file and sets permissions on it
    # Determines what the [dns]/[host] will be, depending on user's arguments
    # Will default to the applications folder name if the [dns]/[host] is not specified
    def init
      webby_ip, host = *options
      host = app_name unless host

      unless file_exists(".pushand")
        log "Initializing deployment descriptor for #{host}..."
        create_file ".pushand", "#! /bin/bash\nphd $0 #{host}\n"
        run "chmod +x .pushand"
      end

      unless file_exists(".gitignore")
        log "Creating .gitignore file..."
        create_file ".gitignore", File.open(File.join(templates_path, 'gitignore')).read
      end

      if dir_exists(".git")
        log "Adding Webbynode remote host to git..."
      else
        log "Initializing git repository..."
      end

      git_init webby_ip, host
    end
    
    # Initializes git unless it already exists
    # Adds git remote for webbynode 
    # Adds an initial commit labled as "Initial Webbynode Commit"
    def git_init(ip, host)
      run "git init" unless dir_exists(".git")
      run "git remote add webbynode git@#{ip}:#{host}"
      run "git add ."
      run "git commit -m \"Initial Webbynode Commit\""
    end
  
  end
end