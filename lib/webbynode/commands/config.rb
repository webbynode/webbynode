module Webbynode::Commands
  class Config < Webbynode::Command
    summary "Creates or changes the current Webbynode API authentication information"
    option :email, "Email to be used for API authentication"
    option :token, "API Token"
    
    def execute
      value = {}
      value[:email] = option(:email) if option(:email)
      value[:token] = option(:token) if option(:token)
      
      api.init_credentials(value)
    end
  end
end