module Webbynode::Commands
  class Init < Webbynode::Command
    include Webbynode::ApiClient
    attr_accessor :output
    
    def out(s)
      (@output ||= "") << s
    end
    
    def execute
      unless params.any?
        out "Usage: webbynode init [webby]"
        return
      end
      
      webby = params[0]
      app_name = params[1] || io.app_name
      
      if webby =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
        webby_ip = webby
      else
        webby_ip = api.ip_for(webby)
      end
      
      git.add_git_ignore unless io.file_exists?(".gitignore")
      
      io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name}\n") unless io.file_exists?(".pushand")
      
      unless git.present?
        git.init 
        git.add "." 
        git.commit "Initial commit"
      end
      
      git.add_remote "webbynode", webby_ip, io.app_name
    rescue Webbynode::GitRemoteAlreadyExistsError
      puts "Webbynode already initialized for this application."
    end
  end
end