require 'httparty'

module Webbynode
  module ApiClient
    CREDENTIALS_FILE = "#{ENV['HOME']}/.webbynode"
    
    def self.included(base)
      base.send(:include, HTTParty)
      base.base_uri "https://manager.webbynode.com/api/yaml"
    end
    
    def webby_ip(hostname)
      (webbies[hostname] || {})[:ip]
    end
    
    def webbies
      webbies = post("/webbies") || {}
      webbies['webbies'].inject({}) { |h, webby| h[webby[:name]] = webby; h }
    end
    
    def credentials
      @credentials || init_credentials
    end
    
    def init_credentials
      @credentials = read_yaml_file(Webbynode::ApiClient::CREDENTIALS_FILE) do
        creds = { :email => ask("Login email: "), :token => ask("API Token:   ") }
        create_yaml_file Webbynode::ApiClient::CREDENTIALS_FILE, creds
        creds
      end
    end
    
    def post(uri, options={})
      self.class.post(uri, { :body => credentials }.merge(options)) 
    end
  end
end