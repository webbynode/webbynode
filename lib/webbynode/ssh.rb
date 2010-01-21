module Webbynode
  class Ssh
    def initialize(remote_ip)
      @remote_ip = remote_ip
    end
    
    def connect
      @conn = nil if @conn and @conn.closed?
      @conn ||= Net::SSH.start(@remote_ip, 'git')
    rescue Net::SSH::AuthenticationFailed
      HighLine.track_eof = false

      @password ||= ask("Enter your password: ") { |q| q.echo = '' }
      @conn     ||= Net::SSH.start(@remote_ip, 'git', :password => @password)
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