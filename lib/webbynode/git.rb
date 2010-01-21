module Webbynode
  class Git
    def initialize(io_handler)
      @io = io_handler
    end
    
    def present?
      @io.directory?(".git")
    end
    
    def init
      if @io.exec("git init") =~ /^Initialized empty Git repository in/
        true
      else
        false
      end
    end
    
    def add_remote(name, host, repo)
      @io.exec("git remote add #{name} git@#{host}:#{repo}").blank?
    end
  end
end
