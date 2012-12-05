module Webbynode
  class ManagerApiClient < ApiClient
    base_uri "https://manager.webbynode.com/api/yaml"

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
    
    def webbies
      unless @webbies
        response = post("/webbies") || {}
        
        @webbies = response
      end
      
      @webbies['webbies'].inject({}) { |h, webby| h[webby['name']] = create_webby(webby); h }
    end

    def create_webby(hash)
      webby = Webby.new
      webby.name = hash['name']
      webby.ip = hash['ip']
      webby.node = hash['node']
      webby.plan = hash['plan']
      webby.status = hash['status']
      webby
    end


    def get(uri, options={})
      response = self.class.get(uri, { :query => credentials }.merge(options))
      if response.code == 401 or response.code == 411
        raise Unauthorized, "You have provided the wrong credentials"
      end
      response
    end
    
    def post(uri, options={})
      body = credentials
      body.merge!(options.delete(:body)||{})

      response = self.class.post(uri, { :body => body }.merge(options))
      if response.code == 401 or response.code == 411
        raise Unauthorized, "You have provided the wrong credentials"
      end
      response
    end

    def check_auth(email, token)
      simple_post("/webbies", :body => { :email => email, :token => token })
    end

    def simple_post(*args)
      self.class.post *args
    end
  end
end