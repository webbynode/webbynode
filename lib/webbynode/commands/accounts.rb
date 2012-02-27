module Webbynode::Commands
  class Accounts < Webbynode::Command
    summary "Manages multiple Webbynode accounts"
    add_alias "account"
    add_alias "acc"
    
    parameter :action, String, "use, new, save, rename, delete or list.", 
      :validate => { :in => ["use", "new", "save", "rename", "delete", "list"] },
      :default  => "list",
      :required => false
    parameter :name, String, "account name", :required => false
    parameter :new_name, String, "new account name", :required => false
    
    Prefix = "#{Webbynode::Io.home_dir}/.webbynode"
    
    attr_accessor :action

    def execute
      @action = param(:action) || "list"
      send(action)
    end
    
    private
    
    def missing_target?
      unless io.file_exists?(target)
        io.log "Account alias #{param(:name).color(:yellow)} not found. Use #{"wn account list".color(:white).bright} for a full list."
        return true
      end      
    end
    
    def target
      @target ||= "#{Prefix}_#{param(:name)}"
    end
    
    def default
      credentials = api.credentials
      io.log "Current account: #{credentials["email"].color(:yellow)}"
    end
    
    def list
      files = io.list_files "#{Prefix}_*"
      
      unless files.any?
        io.log "No accounts found. Use 'wn accounts save' to save current account with an alias."
        return
      end
      
      current = api.credentials["email"]
      files.each do |f|
        if f =~ /\.webbynode_(.*)/
          mark = io.file_matches(f, /email=#{current}/) ? "* " : "  "
          io.log "#{mark.color(:yellow)}#{$1.color(:white).bright}"
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
      account_alias = param(:name).dup
      io.log "Successfully switched to account alias #{account_alias.color(:yellow)}."
    end
    
    def new
      api.init_credentials true
    end
    
    def delete
      return if missing_target?
      io.delete_file target
    end
    
    def rename
      return if missing_target?

      if io.file_exists?("#{Prefix}_#{param(:new_name)}")
        io.log "Account alias #{param(:new_name).color(:yellow)} already exists, use #{"wn account delete".color(:white).bright} to remove it first."
        return
      end
      
      io.rename_file "#{Prefix}_#{param(:name)}", "#{Prefix}_#{param(:new_name)}"
      io.log "Account alias #{param(:name).color(:yellow)} successfully renamed to #{param(:new_name).color(:yellow)}."
    end
  end
end
