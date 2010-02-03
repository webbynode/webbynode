module Webbynode::Commands
  class Init < Webbynode::Command
    summary "Prepares the application on current folder for deployment"
    parameter :webby, String, "Name or IP of the Webby to deploy to"
    parameter :dns, String, "The DNS used for this application", :required => false
    option :adddns, "Creates the DNS entries for the domain"
    option :engine, "Sets the application engine for the app", :validate => { :in => ['php', 'rack', 'rails'] }
    
    def execute
      unless params.any?
        io.log help
        return
      end
      
      webby     = param(:webby)
      app_name  = io.app_name
      
      if param(:dns)
        dns_entry = "#{param(:dns)}" 
      else
        dns_entry = app_name
      end
      
      io.log "Initializing application #{app_name} #{dns_entry ? "with dns #{dns_entry}" : ""}", :start
      
      if webby =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
        webby_ip = webby
      else
        begin
          io.log "Retrieving IP for Webby #{webby}...", :action
          webby_ip = api.ip_for(webby)
          unless webby_ip
            if (webbies = api.webbies.keys) and webbies.any?
              raise CommandError, 
                "Couldn't find Webby '#{webby}' on your account. Your Webbies are: #{webbies.map { |w| "'#{w}'"}.to_phrase}."
            else
              raise CommandError, "You don't have any active Webbies on your account."
            end
          end
        end
      end
      
      io.log "Initializing directory structure...", :action
      git.add_git_ignore unless io.file_exists?(".gitignore")

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

      io.add_setting("engine", option(:engine)) if option(:engine)
      
      unless git.present?
        io.log "Initializing git and applying initial commit...", :action
        git.init 
        git.add "." 
        git.commit "Initial commit"
      end
      
      io.log "Adding webbynode as git remote...", :action
      git.add_remote "webbynode", webby_ip, app_name
      
      handle_dns param(:dns) if option(:adddns)
      
      io.log "Application #{app_name} ready for Rapid Deployment", :finish
    rescue Webbynode::GitRemoteAlreadyExistsError
      io.log "Application already initialized.", true
    end
  end
end