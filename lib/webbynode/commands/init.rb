module Webbynode::Commands
  class Init < Webbynode::Command
    attr_accessor :output
    
    def out(s)
      (@output ||= "") << s
    end
    
    def execute
      unless params.any?
        out "Usage: webbynode init [webby]"
        return
      end
      
      git.add_git_ignore unless io.file_exists?(".gitignore")
      
      io.create_file(".pushand", "#! /bin/bash\nphd $0 #{io.app_name}\n") unless io.file_exists?(".pushand")
      
      unless git.present?
        git.init 
        git.add "." 
        git.commit "Initial commit"
      end
      
      git.add_remote "webbynode", params[0], io.app_name
    rescue Webbynode::GitRemoteAlreadyExistsError
      puts "Webbynode already initialized for this application."
    end
  end
end