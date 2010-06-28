module Webbynode::Commands
  class Init < Webbynode::Command
    summary "Prepares the application on current folder for deployment"
    parameter :webby, String, "Name or IP of the Webby to deploy to", :required => false
    option :dns, String, "The DNS used for this application"
    option :adddns, "Creates the DNS entries for the domain"
    option :engine, "Sets the application engine for the app", :validate => { :in => ['php', 'rack', 'rails', 'rails3'] }
    
    def execute
      unless params.any?
        io.log help
        return
      end
      
      check_gemfile
      
      webby       = param(:webby)
      app_name    = io.app_name
      git_present = git.present?
      
      if option(:dns)
        dns_entry = "#{option(:dns)}" 
      else
        dns_entry = app_name
      end

      if git_present and !git.clean?
        raise CommandError, 
          "Cannot initialize: git has pending changes. Execute a git commit or add changes to .gitignore and try again."
      end
      
      io.log "Initializing application #{app_name} #{dns_entry ? "with dns #{dns_entry}" : ""}", :start
      
      webby_ip = get_ip(webby)
      
      io.log "Initializing directory structure...", :action
      git.remove("config/database.yml") if git.tracks?("config/database.yml")
      git.remove("db/schema.rb")        if git.tracks?("db/schema.rb")
      
      if io.file_exists?(".gitignore")
        git.add_to_git_ignore("config/database.yml", "db/schema.rb")
      else
        git.add_git_ignore 
      end

      unless io.file_exists?(".pushand")
        io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name} #{dns_entry}\n", true)
      end
      
      unless io.directory?(".webbynode")
        io.exec("mkdir -p .webbynode/tasks") 
        io.create_file(".webbynode/tasks/after_push", "")
        io.create_file(".webbynode/tasks/before_push", "")
        io.create_file(".webbynode/aliases", "")
        io.create_file(".webbynode/config", "")
      end

      detect_engine
      
      unless git_present
        io.log "Initializing git and applying initial commit...", :action
        git.init 
        git.add "." 
        git.commit "Initial commit"
      end
      
      if git.remote_exists?('webbynode')
        if ask('Webbynode already initialized. Do you want to overwrite the current settings (y/n)?').downcase == 'y'
          git.delete_remote('webbynode')
        end
      end
      
      if !git.remote_exists?('webbynode') and git_present
        io.log "Commiting Webbynode changes...", :action
        git.add "." 
        git.commit2 "[Webbynode] Rapid App Deployment Initialization"
      end
      
      io.log "Adding webbynode as git remote...", :action
      git.add_remote "webbynode", webby_ip, app_name
      
      handle_dns option(:dns) if option(:adddns)
      
      io.log "Application #{app_name} ready for Rapid Deployment", :finish
    rescue Webbynode::GitRemoteAlreadyExistsError
      io.log "Application already initialized.", true
    end
    
    private
    
    def get_ip(webby)
      return webby if webby =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
        
      api_webbies = api.webbies
      
      unless webby
        # TODO: raise CommandError id size = 0
        return api_webbies[api_webbies.keys.first][:ip] if api_webbies.keys.size == 1

        io.log "Current Webbies in your account:", :action
        io.log ""
        api_webbies.keys.each do |webby_key|
          webby = api_webbies[webby_key]
          io.log "  - #{webby[:name]} (#{webby[:ip]})", :action
        end
        
        io.log ""
        webby = ask("Which webby do you want to deploy to:")
      end

      io.log "Retrieving IP for Webby #{webby}...", :action
      webby_ip = api.ip_for(webby)

      unless webby_ip
        if (webbies = api_webbies.keys) and webbies.any?
          raise CommandError, 
            "Couldn't find Webby '#{webby}' on your account. Your Webbies are: #{webbies.map { |w| "'#{w}'"}.to_phrase}."
        else
          raise CommandError, "You don't have any active Webbies on your account."
        end
      end
      
      webby_ip
    end
    
    def detect_engine
      unless engine = option(:engine)
        if rails3?
          io.log "Detected Rails 3 application...", :action
          engine = "rails3" 
        end
      end
      
      io.add_setting "engine", engine if engine
    end
    
    def rails3?
      io.file_exists?("script/rails")
    end
    
    def check_gemfile
      return unless gemfile.present?
      
      dependencies = gemfile.dependencies(:without => [:development, :test])
      if dependencies.include? 'sqlite3-ruby'
        raise CommandError, <<-EOS

Gemfile dependency problem.

The following gem dependency was found in your Gemfile:

  gem 'sqlite3-ruby', :require => 'sqlite3'
  
This dependency will cause an error in production when using Passenger. We recommend you remove it.
Also, be sure to define the database driver gem for the database type you are using in production (either the mysql or the pg gem).

  gem 'mysql'
  
  -or-
  
  gem 'pg'
  
If you would like to use SQLite3 in your development and test environments,
you may do so by wrapping the gem definition inside the :test and :development groups.

  group :test do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end
  
  -or-
  
  group :development do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end
  
To learn more about this issue, visit:

  http://guides.webbynode.com/articles/rapidapps/rails3warning.html
  
EOS
      end
    end
  end
end