module Webbynode::Commands
  class Init < Webbynode::Command
    attr_accessor :output
    
    def out(s)
      (@output ||= "") << s
    end
    
    def run(params=[], options={})
      unless params.any?
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