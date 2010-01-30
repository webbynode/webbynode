require 'httparty'

module Webbynode
  class ApiClient
    include HTTParty
    base_uri "https://manager.webbynode.com/api/yaml"

    CREDENTIALS_FILE = "#{ENV['HOME']}/.webbynode"
    Unauthorized = Class.new(StandardError)
    
    def io
      @io ||= Io.new
    end
    
    def ip_for(hostname)
      (webbies[hostname] || {})[:ip]
    end
    
    def webbies
      unless @webbies
        response = post("/webbies") || {}
        if response.code == 401 or response.code == 411
          raise Unauthorized, "You have provided the wrong credentials"
        end
        
        @webbies = response
      end
      
      @webbies['webbies'].inject({}) { |h, webby| h[webby[:name]] = webby; h }
    end
    
    def credentials
      @credentials ||= init_credentials
    end
    
    def init_credentials
      creds = if io.file_exists?(CREDENTIALS_FILE)
        io.read_config(CREDENTIALS_FILE)
      else
        email = ask("Login email: ")
        token = ask("API token:   ")
        response = self.class.post("/webbies", { :email => email, :token => token })
        if response.code == 401 or response.code == 411
          raise Unauthorized, "You have provided the wrong credentials"
        end
        io.create_file(CREDENTIALS_FILE, "email = #{email}\ntoken = #{token}\n")
        { :email => email, :token => token }
      end
    end
    
    def post(uri, options={})
      self.class.post(uri, { :body => credentials }.merge(options))
    end
  end
end