module Webbynode::Commands
  class Config < Webbynode::Command
    summary "Adds or changes your Webbynode API credentials"
    option :email, "The email you use on Webbymanager"
    option :token, "The API Token, found on Account section of Webbymanager"
    
    def execute
      value = {}
      value[:email] = option(:email) if option(:email)
      value[:token] = option(:token) if option(:token)
      
      api.init_credentials(value)
    end
  end
end