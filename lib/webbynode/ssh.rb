module Webbynode
  class Ssh
    def initialize(remote_ip)
      @remote_ip = remote_ip
    end
    
    def io
      @io ||= Webbynode::Io.new
    end
    
    def connect
      raise "No IP given" unless @remote_ip
      @conn = nil if @conn and @conn.closed?
      @conn ||= Net::SSH.start(@remote_ip, 'git', :auth_methods => %w(publickey hostbased))
    rescue Net::SSH::AuthenticationFailed
      HighLine.track_eof = false
      
      begin
        @password ||= ask("Enter your deployment password for #{@remote_ip}: ") { |q| q.echo = '' }
        @conn     ||= Net::SSH.start(@remote_ip, 'git', :password => @password)  
      rescue Net::SSH::AuthenticationFailed
        io.log "Could not connect to server: invalid authentication.", true
        exit
      end
      
    rescue Net::SSH::Disconnect
      io.log "Could not connect to the server: Wrong IP or Server Offline.", true
      exit
    
    end
    
    def execute(script, echo=false)
      connect
      output = ""
      error_output = ""
      
      exit_code = nil
      channel = @conn.open_channel do |chan|
        chan.on_request('exit-status') do |ch, data|
          exit_code = data.read_long
        end
        
        chan.on_data do |ch, data|
          puts data if echo
          output << data
        end
        
        chan.on_extended_data do |ch, type, data|
          next unless type == 1  # only handle stderr
          puts data if echo
          output << data
          error_output << data
        end
        
        chan.exec("#{script} < /dev/null") do |ch, s|
          raise Exceptions::SshInstallationError, "Error executing script \"#{script[:name]}\"" unless s
        end
      end
      
      channel.wait
      
      output
    end
  end
end