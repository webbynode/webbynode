module Webbynode::Commands
  class AddBackup < Webbynode::Command
    option :retain, "Number of backups to retain on S3 (one backup per day), default is 30", :take => :days
    
    def execute
      key    = io.general_settings['aws_key']   
      secret = io.general_settings['aws_secret']
      
      unless key and secret
        puts io.read_from_template("backup")
        
        key    = ask("AWS key: ")
        secret = ask("AWS secret: ") unless key.blank?
        
        if key.blank? or secret.blank?
          puts 
          puts "Aborted."
          return
        end
        
        io.add_general_setting("aws_key", key)
        io.add_general_setting("aws_secret", secret)
      end

      app_name = io.app_name
      io.log "Configuring backup for #{app_name}...", :start
      
      retain = option(:retain)
      remote_executor.exec %Q(config_app_backup #{app_name} "#{key}" "#{secret}"#{retain.blank? ? "" : " #{retain}"}), true
    end
  end
end