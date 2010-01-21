module Webbynode
  class GitNotRepoError < StandardError; end
  class GitRemoteAlreadyExistsError < StandardError; end

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
    
    def add(what)
      @io.exec "git add #{what}"
    end
    
    def add_remote(name, host, repo)
      output = @io.exec("git remote add #{name} git@#{host}:#{repo}")
      
      if output =~ /Not a git repository/
        raise GitNotRepoError, output
      elsif output =~ /remote \w+ already exists/
        raise GitRemoteAlreadyExistsError, output
      end
      
      output.blank?
    end
  end
end
