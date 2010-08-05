require 'httparty'

module Webbynode
  class ApiClient
    include HTTParty
    base_uri "https://manager.webbynode.com/api/yaml"

    CREDENTIALS_FILE = "#{ENV['HOME']}/.webbynode"

    Unauthorized = Class.new(StandardError)
    InactiveZone = Class.new(StandardError)
    ApiError = Class.new(StandardError)
    
    def io
      @io ||= Io.new
    end
    
    def zones
      response = post("/dns")
      if zones = response["zones"]
        zones.inject({}) { |h, zone| h[zone[:domain]] = zone; h }
      end
    end
    
    def create_record(record, ip)
      original_record = record

      url = Domainatrix.parse("http://#{record}")
      record = url.subdomain
      domain = "#{url.domain}.#{url.public_suffix}."
      
      zone = zones[domain]
      if zone
        raise InactiveZone, domain unless zone[:status] == 'Active'
      else
        zone = create_zone(domain)
      end

      create_a_record(zone[:id], record, ip, original_record)
    end
    
    def create_zone(zone)
      response = post("/dns/new", :query => {"zone[domain]" => zone, "zone[ttl]" => "86400"})
      handle_error(response)
      response
    end
    
    def create_a_record(id, record, ip, original_record)
      response = post("/dns/#{id}/records/new", :query => {"record[name]" => record, "record[type]" => "A", "record[data]" => ip})
      if response["errors"] and response["errors"] =~ /Data has already been taken/
        io.log "'#{original_record}' is already setup on Webbynode DNS, make sure it's pointing to #{ip}", :warning
        return
      end
      
      handle_error(response)
      response["record"]
    end
    
    def handle_error(response)
      raise ApiError, response["error"] if response["error"]
      raise ApiError, "invalid response from the API (code #{response.code})" unless response.code == 200
    end
    
    def ip_for(hostname)
      (webbies[hostname] || {})['ip']
    end
    
    def webbies
      unless @webbies
        response = post("/webbies") || {}
        
        @webbies = response
      end
      
      @webbies['webbies'].inject({}) { |h, webby| h[webby['name']] = webby; h }
    end
    
    def credentials
      @credentials ||= init_credentials
    end
    
    def init_credentials(overwrite=false)
      creds = if io.file_exists?(CREDENTIALS_FILE) and !overwrite
        properties
      else
        email = overwrite[:email] if overwrite.is_a?(Hash) and overwrite[:email]
        token = overwrite[:token] if overwrite.is_a?(Hash) and overwrite[:token]
        
        puts io.read_from_template("api_token") unless email and token

        email ||= ask("Login email: ")
        token ||= ask("API token:   ")
        
        response = self.class.post("/webbies", :body => { :email => email, :token => token })
        if response.code == 401 or response.code == 411
          raise Unauthorized, "You have provided the wrong credentials"
        end

        properties['email'] = email
        properties['token'] = token
        properties.save
        
        puts

        { :email => email, :token => token }
      end
    end
    
    def properties
      @properties ||= Webbynode::Properties.new(CREDENTIALS_FILE)
    end
    
    def post(uri, options={})
      response = self.class.post(uri, { :body => credentials }.merge(options))
      if response.code == 401 or response.code == 411
        raise Unauthorized, "You have provided the wrong credentials"
      end
      response
    end
  end
end