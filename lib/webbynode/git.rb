module Webbynode
  class GitError < StandardError; end
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
      exec("git init") do |output|
        # this indicates init was properly executed
        output =~ /^Initialized empty Git repository in/
      end
    end
    
    def add(what)
      exec "git add #{what}"
    end
    
    def add_remote(name, host, repo)
      exec("git remote add #{name} git@#{host}:#{repo}") do |output|
        # raise an exception if remote already exists
        raise GitRemoteAlreadyExistsError, output if output =~ /remote \w+ already exists/
        
        # success if output is empty
        output.blank?
      end
    end
    
    private
    
    def exec(cmd, &blk)
      handle_output @io.exec(cmd), &blk
    end
    
    def handle_output(output, &blk)
      raise GitNotRepoError, output if output =~ /Not a git repository/

      if blk
        raise GitError, output unless blk.call(output)
      else
        raise GitError, output unless output.blank?
      end
      
      true
    end
  end
end
