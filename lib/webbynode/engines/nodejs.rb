module Webbynode::Engines
  class NodeJS
    include Engine
    set_name "NodeJS"

    def detected?
      io.file_exists?('server.js') || io.file_exists?('app.js')
    end
    
    def prepare
      default_port = 8000
      if io.file_exists?('server.js')
        contents = io.read_file('server.js')
        if contents =~ /listen\((\d+)\)/
          default_port = $1
        end
      elsif io.file_exists?('app.js')
        content = io.read_file('app.js')
        if content =~ /listen\((\d+)\)/
          default_port = $1
        end
      end

      
      io.log ""
      io.log "Configure NodeJS Application"
      io.log ""

      while true
        proxy = ask("  Proxy requests (Y/n) [Y]? ")
        proxy = 'Y' if proxy.blank?
        break if "YN".include?(proxy.to_s.upcase)
        io.log ""
        io.log "  Please answer Y=use proxy or N=don't use proxy (standalone NodeJS app)"
      end
      
      while true
        port = ask("     Listening port [#{default_port}]: ")
        port = "#{default_port}" if port.blank?
        break if port.to_i.to_s == port.to_s
        io.log ""
        io.log "  Please enter a numeric value for port"
      end
      
      io.add_setting('nodejs_proxy', proxy)
      io.add_setting('nodejs_port',  port.to_s)
    end
  end
end
