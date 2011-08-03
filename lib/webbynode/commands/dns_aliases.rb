module Webbynode::Commands
  class DnsAliases < Webbynode::Command
    requires_initialization!

    summary "Changes the DNS aliases for this application"

    parameter :action, String, "add, remove or show.", 
      :validate => { :in => ["add", "remove", "show"] },
      :default  => "show",
      :required => false
    parameter :alias, String, "alias", :required => false
    
    attr_accessor :action, :aliases
    
    def execute
      @aliases = load_aliases
      @action = param(:action) || "show"
      send(action)
    end
    
    private
    
    def show
      if aliases.any?
        io.log("Current aliases: #{aliases.join(' ').color(:yellow)}")
      else
        io.log("No current aliases. To add new aliases use:\n\n  #{"#{File.basename $0} dns_aliases add ".color(:yellow)}new-dns-alias")
      end
    end
    
    def add
      new_alias = param(:alias)
      
      if aliases.include?(new_alias)
        io.log "Alias #{new_alias.color(:yellow)} already exists."
      else
        aliases << new_alias
        save_aliases

        io.log "Alias #{new_alias.color(:yellow)} added."
        show
      end
    end
    
    def remove
      to_remove = param(:alias)
      
      if aliases.include?(to_remove)
        aliases.delete to_remove
        save_aliases

        io.log "Alias #{to_remove.color(:yellow)} removed."
        show
      else
        io.log "Alias #{to_remove.color(:yellow)} doesn't exist."
      end
    end
    
    def load_aliases
      dns_alias = io.load_setting('dns_alias')
      return [] unless dns_alias
      
      aliases = dns_alias[/'(.*)'/, 1] || dns_alias
      aliases.split
    end
    
    def save_aliases
      io.add_setting('dns_alias', "'#{aliases.join(' ')}'")
    end
  end
end