module Webbynode
  class ApiClient
    include HTTParty
    CREDENTIALS_FILE = "#{Io.home_dir}/.webbynode"

    Unauthorized = Class.new(StandardError)
    InactiveZone = Class.new(StandardError)
    ApiError = Class.new(StandardError)

    def io
      @io ||= Io.new
    end

    def self.system
      ApiClient.new.credentials['system']
    end

    def self.instance
      instance_for(system)
    end

    def self.instance_for(system)
      if system == "manager2"
        Manager2ApiClient.new
      else
        ManagerApiClient.new
      end
    end
    
    def ip_for(hostname)
      if webby = webbies[hostname]
        webby.ip
      end
    end
    
    def handle_error(response)
      raise ApiError, response["error"] if response["error"]
      raise ApiError, format_error(response["errors"]) if response["errors"]
      raise ApiError, "invalid response from the API (code #{response.code})" unless response.code == 200
    end

    def format_error(error_hash)
      output = []
      error_hash.each_pair do |field, errors|
        errors.each do |error|
          output << "#{field} #{error}"
        end
      end

      output.join(", ")
    end
    
    def credentials
      @credentials ||= init_credentials
    end
    
    def init_credentials(overwrite=false)
      creds = if io.file_exists?(CREDENTIALS_FILE) and !overwrite
        properties
      else
        system = overwrite[:system] if overwrite.is_a?(Hash) and overwrite[:system] 
        email = overwrite[:email] if overwrite.is_a?(Hash) and overwrite[:email]
        token = overwrite[:token] if overwrite.is_a?(Hash) and overwrite[:token]
        
        io.log io.read_from_template("api_token") unless email and token and system

        system ||= ask("What's the end point you're using - manager or manager2? ")
        email  ||= ask("Login email: ")
        token  ||= ask("API token:   ")

        puts ""
        
        response = ApiClient.instance_for(system).check_auth(email, token)
        if response.code == 401 or response.code == 411
          raise Unauthorized, "You have provided the wrong credentials"
        end

        properties['email'] = email
        properties['token'] = token
        properties['system'] = system
        properties.save
        
        { :email => email, :token => token, :system => system }
      end
    end
    
    def properties
      @properties ||= Webbynode::Properties.new(CREDENTIALS_FILE)
    end
  end
end