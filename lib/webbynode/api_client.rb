require 'httparty'

module Webbynode
  class ApiClient
    include HTTParty
    base_uri "https://manager.webbynode.com/api/yaml"

    CREDENTIALS_FILE = "#{ENV['HOME']}/.webbynode"
    
    def io
      @io ||= Io.new
    end
    
    def ip_for(hostname)
      (webbies[hostname] || {})[:ip]
    end
    
    def webbies
      webbies = post("/webbies") || {}
      webbies['webbies'].inject({}) { |h, webby| h[webby[:name]] = webby; h }
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
        io.create_file(CREDENTIALS_FILE, "email = #{email}\ntoken = #{token}\n")
      end
    end
    
    def post(uri, options={})
      self.class.post(uri, { :body => credentials }.merge(options))
    end
  end
end