module Webbynode::Commands
  class User < Webbynode::Command
    summary "Manages Rapp Trial user"
    parameter :action, 'Action to perform', :validate => { :in => ['add', 'remove', 'show', 'password']}
    
    def execute
      email = ask('Email: ')
      user = ask('Username: ')
      pass = ask('Password: ') { |q| q.echo = false }

      response = Webbynode::Trial.add_user(user, pass, email)
      puts response["message"]
    end
  end
end