module Webbynode::Commands
  class User < Webbynode::Command
    summary "Manages Rapp Trial user"
    parameter :action, 'Action to perform', :validate => { :in => ['add', 'remove', 'show', 'password']}
    
    def execute
      io.log "Rapp Trial - http://rapp.webbynode.com"
      io.log ""
      
      if user = io.general_settings['rapp_username']
        io.log "User #{user} is already configured for Rapp Trial."
        if ask('Do you want to overwrite this settings (y/n)?') != 'y'
          io.log ""
          io.log "Aborted."
          return
        end 
      end
      
      io.log "Rapp Trial is a good way to try Webbynode's Rapp Engine without being a subscriber."
      io.log "You can deploy your application and it will be online for up to 24 hours. We delete"
      io.log "all applications at 2AM EST, but your user will remain valid."
      io.log ""
      io.log "Please enter your email below."
      io.log ""

      begin
        email = ask('Email: ') 
      end until valid_email?(email)
      
      io.log ""
      io.log "Enter an username and password to start using Rapp Trial."
      io.log ""
      
      begin
        user = ask('         Username: ') 
      end until valid_user?(user)
      
      begin
        begin
          pass = ask('Choose a password: ') { |q| q.echo = "*" }
        end until valid_pass?(pass)
        conf = ask('   Enter it again: ') { |q| q.echo = "*" }
      end until valid_conf?(pass, conf)

      response = Webbynode::Trial.add_user(user, pass, email)
      
      io.log ""
      
      if response["success"]
        io.add_general_setting "rapp_username", user
        puts response["message"]
      else
        puts "ERROR: #{response["message"]}"
      end
    end
    
    private
    
    def valid_email?(email)
      if email.nil? or email.empty?
        io.log "Your email is required. Try again."
        io.log "" 
        
        return false
      end
      
      return true if email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
      
      io.log "'#{email}' is not a valid email. Try again."
      io.log "" 
    end
    
    def valid_user?(user)
      return true if user =~ /^[a-z0-9_-]{3,15}$/
      
      io.log "Invalid user name. Use lowercase chars, numbers and underscore only. Length must be 3 to 15."
      io.log ""
    end
    
    def valid_pass?(pass)
      return true if pass =~ /^[A-Za-z]\w{5,}$/

      io.log "Password must start with a letter and must have at least 6 characters. Try again."
      io.log ""
    end
    
    def valid_conf?(pass, conf)
      return true if pass == conf

      io.log "Password doesn't match confirmation. Try again."
      io.log ""
    end
  end
end