module Webbynode::Commands
  class Init < Webbynode::Command
    description "Initializes the current folder as a deployable application"
    parameter :webby, String, "Name or IP of the Webby to deploy to"
    parameter :dns, String, "The DNS used for this application", :required => false
    option :passphrase, String, "If present, passphrase will be used when creating a new SSH key", :take => :words
    
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
        webby_ip = api.ip_for(webby)
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
      
      io.log "Webbynode has been initialized for this application!", true
    rescue Webbynode::GitRemoteAlreadyExistsError
      io.log "Webbynode already initialized for this application.", true
    end
  end
end