module Webbynode
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
      
      unless webby_ip
        log_and_exit read_template('help')
        return
      end
      
      unless webby_ip =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
        webby_ip = webby_ip(webby_ip)
      end

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

      # @ Felipe
      #
      # Now also passes the host to the git_init method
      # Notice how I replaced the "git remote add webbynode git@#{ip}:{app_name}"
      # to "git remote add webbynode git@#{ip}:{HOST}"
      #
      # Is this a good idea? The reason I did this is because when you execute
      # webbynode remote 'ls -la' to read out the directory, it parses the .pushand file to
      # fetch the [host]. However, what apparently happens is that the folder on the remote server
      # would always be named after the folder on the local machine (app_name) in this case.
      # So I changed this app_name to host inside the git_init method so that if you for example execute:
      #
      # webbynode init 2.2.2.2 dev.webbynode.com
      #
      # It will create for example: /var/rails/dev.webbynode.com, which, also is in my opinion better than just webbynode
      # because if you want to have subdomains (such as that dev. (development) subdomain, it's more clear as to what is the main and what is the subdomain)
      #
      # One problem (which should be easy to solve but I think it's serverside) is that it apparently attempts to create a user for the MySQL and PostgreSQL database.
      # And as we both know it will most likely fail when it creates a user with the username: dev.webbynode.com instead. I deployed an app, and this seemed to be the case.
      # It failed to create a database and migrate it because it couldn't find the user, which most likely cannot be created due to the name I think. So I changed it to root
      # manually inside the config/database.yml and it worked again.
      #
      # What do you think?
      #
      # Here is an example of what got rendered as database.yml on my Webby
      #
      # # inside: /var/rails/test.wizardry-ls.com/config/database.yml
      # production:
      #   adapter: mysql
      #   encoding: utf8
      #   database: test.wizardry-ls.com # <= Will fail
      #   username: test.wizardry-ls.com # <= Will fail
      #   password: mypassword
      #
      # I think we should always strip out "any" characters for the database.yml that aren't characters/digits. So that you end up always having alphanumeric.
      # The only issue is the database.yml on this part as far as I can see. If we can fix it so it will remove any non [a-zA-z0-9] characters then it should work
      # right out of the box.
      #
      git_init(webby_ip, host)
    end
    
    
    # Adds user's public SSH key to a Webby
    def addkey
      key = "#{ENV['HOME']}/.ssh/id_rsa.pub"
      run "ssh-keygen -t rsa -N \"#{named_options["passphrase"]}\" -f #{key}" unless File.exists?(key)

      key_contents = File.read(key)
      run_remote_command "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; echo \"#{key_contents}\" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"
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
    
    # Returns the version to the user
    def version
      log "Webbynode Rapid Deployment Gem v#{Webbynode::VERSION}"
    end
  
  end
end