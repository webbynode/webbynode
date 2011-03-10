module Webbynode::Commands
  class Accounts < Webbynode::Command
    summary "Manages multiple Webbynode accounts"
    
    Prefix = "#{Webbynode::Io.home_dir}/.webbynode"
    
    attr_accessor :action

    parameter :action, String, "use, new, save, delete or list.", 
      :validate => { :in => ["use", "new", "save", "delete", "list"] },
      :default  => "list",
      :required => false
    parameter :name, String, "account name", :required => false
    
    def execute
      @action = param(:action) || "default"
      send(action)
    end
    
    private
    
    def missing_target?
      unless io.file_exists?(target)
        io.log "Account alias '#{param(:name)}' not found. Use 'wn account list' for a full list."
        return true
      end      
    end
    
    def target
      @target ||= "#{Prefix}_#{param(:name)}"
    end
    
    def default
      credentials = api.credentials
      io.log "Current account: #{credentials["email"]}"
    end
    
    def list
      files = io.list_files "#{Prefix}_*"
      
      unless files.any?
        io.log "No accounts found. Use 'wn accounts save' to save current account with an alias."
        return
      end
      
      files.each do |f|
        if f =~ /\.webbynode_(.*)/
          io.log $1
        end
      end
    end
    
    def save
      if io.file_exists?(target) and ask("Do you want to overwrite saved account name (y/n)? ").downcase != "y"
        io.log "Save aborted."
        return
      end
        
      io.copy_file "#{Prefix}", target
    end
    
    def use
      return if missing_target?
      io.copy_file target, "#{Prefix}"
    end
    
    def new
      api.init_credentials true
    end
    
    def delete
      return if missing_target?
      io.delete_file target
    end
  end
end
