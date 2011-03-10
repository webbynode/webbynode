module Webbynode::Commands
  class Accounts < Webbynode::Command
    summary "Manages multiple Webbynode accounts"
    
    Prefix = "#{Webbynode::Io.home_dir}/.webbynode"
    
    attr_accessor :action

    parameter :action, String, "use, new, save, delete or list.", 
      :validate => { :in => ["use", "new", "save", "delete", "list"] },
      :default  => "list"
    parameter :name, String, "account name", :required => false
    
    def execute
      @action = param(:action) || "default"
      send(action)
    end
    
    private
    
    def default
      credentials = api.credentials
      io.log "Current account: #{credentials[:email]}"
    end
    
    def list
      files = io.list_files "#{Prefix}_*"
      files.each do |f|
        if f =~ /\.webbynode_(.*)/
          io.log $1
        end
      end
    end
    
    def save
      io.copy_file "#{Prefix}", "#{Prefix}_#{param(:name)}"
    end
    
    def use
      io.copy_file "#{Prefix}_#{param(:name)}", "#{Prefix}"
    end
    
    def new
      api.init_credentials true
    end
  end
end
