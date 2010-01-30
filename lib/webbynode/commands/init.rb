module Webbynode::Commands
  class Init < Webbynode::Command
    description "Initializes the current folder as a deployable application"
    parameter :webby, String, "Name or IP of the Webby to deploy to"
    parameter :dns, String, "The DNS used for this application", :required => false
    option :dns, "Creates the DNS entries for the domain"
    
    def execute
      unless params.any?
        io.log help
        return
      end
      
      webby     = param(:webby)
      app_name  = param(:dns) || io.app_name
      
      if webby =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
        webby_ip = webby
      else
        begin
          webby_ip = api.ip_for(webby)
          unless webby_ip
            if (webbies = api.webbies.keys) and webbies.any?
              raise CommandError, 
                "Couldn't find Webby '#{webby}' on your account. Your Webbies are: #{webbies.map { |w| "'#{w}'"}.to_phrase}."
            else
              raise CommandError, "You don't have any active Webbies on your account."
            end
          end
        rescue Webbynode::ApiClient::Unauthorized
          raise CommandError, "Your credentials didn't match any Webbynode account."
        end
      end
      
      unless io.file_exists?(".gitignore")
        git.add_git_ignore
      end
      
      unless io.file_exists?(".pushand")
        io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name}\n")
      end
      
      unless git.present?
        git.init 
        git.add "." 
        git.commit "Initial commit"
      end
      
      unless io.directory?(".webbynode")
        io.exec("mkdir .webbynode")
      end
      
      git.add_remote "webbynode", webby_ip, app_name
      
      if option(:dns)
        handle_dns
      end
      
      io.log "Webbynode has been initialized for this application!", true
    rescue Webbynode::GitRemoteAlreadyExistsError
      io.log "Webbynode already initialized for this application.", true
    end
  
    def handle_dns
      api.create_record param(:dns), git.parse_remote_ip
    rescue Webbynode::ApiClient::ApiError
      if $!.message =~ /Data has already been taken/
        io.log "The DNS entry for '#{param(:dns)}' already existed, ignoring."
      else
        io.log "Couldn't create your DNS entry: #{$!.message}"
      end
    end
  end
end