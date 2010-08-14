module Webbynode
  class Trial
    include HTTParty
    base_uri "http://trial.webbyapp.com"
    format :yaml
    
    def self.add_user(user, password, email)
      put('/users', :body => { :username => user, :password => password, :email => email })
    end
  end
end