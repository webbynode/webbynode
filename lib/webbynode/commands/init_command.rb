module Webbynode
  class InitCommand
    attr_accessor :output, :params
    
    def initialize(params)
      @params = params
      @output = ""
    end
    
    def out(s)
      @output << s
    end
    
    def run
      unless params
        out "Usage: webbynode init [webby]"
        return
      end
      
      unless git.present?
        git.init 
        git.add "." 
        git.commit "Initial commit"
      end
      
      git.add_remote "webbynode", "1.2.3.4", io.app_name
    end
  end
end