module Webbynode
  class Manager2ApiClient < ApiClient
    base_uri "https://manager2.webbynode.com/api"

    def zones
      response = get("/zones.json")
      if zones = response
        zones.inject({}) { |h, zone| h[zone['name']] = zone; h }
      end
    end
    
    def create_zone(zone)
      response = post("/zones.json", :query => {"zone[name]" => zone})
      handle_error(response)
      response
    end
    
    def create_record(record, ip)
      original_record = record

      url = Domainatrix.parse("http://#{record}")
      record = url.subdomain
      domain = "#{url.domain}.#{url.public_suffix}"

      zone = zones[domain] || create_zone(domain)

      create_a_record(zone['id'], record, ip, original_record)
    end
    
    def create_a_record(id, record, ip, original_record)
      response = post("/zones/#{id}/records.json", :body => {"record[name]" => record, "record[type]" => "A", "record[content]" => ip})
      if response["errors"] and format_error(response["errors"]) =~ /content has already been taken/
        io.log "'#{original_record}' already exists in Webbynode DNS, make sure it's pointing to #{ip}", :warning
        return
      end
      if response.code == 404
        raise Manager2ApiClient::ApiError, "this domain was not found under your account"
      end
      
      handle_error(response)
      response
    end
    
    def webbies
      unless @webbies
        response = get("/webbies.json") || {}
        @webbies = response
      end
      
      @webbies.inject({}) { |h, webby| h[webby['hostname']] = create_webby(webby); h }
    end

    def create_webby(hash)
      webby = Webby.new
      webby.name = hash['hostname']
      webby.ip = hash['mainipaddress']
      webby.node = hash['node_name']
      webby.plan = hash['plan']
      webby.status = hash['status']
      webby
    end

    def fix_credentials
      { :auth_token => credentials['token'] }
    end

    def get(uri, options={})
      response = self.class.get(uri, { :query => fix_credentials }.merge(options))
      if response.code == 401 or response.code == 411
        raise Unauthorized, "You have provided the wrong credentials"
      end
      response
    end
    
    def post(uri, options={})
      body = fix_credentials
      body.merge!(options.delete(:body)||{})

      response = self.class.post(uri, { :body => body }.merge(options))
      if response.code == 401 or response.code == 411
        raise Unauthorized, "You have provided the wrong credentials"
      end
      response
    end

    def check_auth(email, token)
      simple_post("/webbies.json", :body => { :auth_token => token })
    end

    def simple_post(*args)
      self.class.post *args
    end
  end
end
