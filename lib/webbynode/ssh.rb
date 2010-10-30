module Webbynode
  class Ssh
    attr_accessor :remote_ip, :port, :user
    
    def initialize(remote_ip, user='git', port=22)
      @remote_ip = remote_ip
      @user = user
      @port = port
    end
    
    def io
      @io ||= Webbynode::Io.new
    end
    
    def connect
      raise "No IP given" unless @remote_ip
      @conn = nil if @conn and @conn.closed?
      @conn ||= Net::SSH.start(@remote_ip, @user, :port => @port, :auth_methods => %w(publickey hostbased))
    rescue Net::SSH::AuthenticationFailed
      HighLine.track_eof = false
      
      begin
        @password ||= ask("Enter your deployment password for #{@user}@#{@remote_ip}: ") { |q| q.echo = '' }
        @conn     ||= Net::SSH.start(@remote_ip, @user, :port => @port, :password => @password)  
      rescue Net::SSH::AuthenticationFailed
        io.log "Could not connect to server: invalid authentication."
        exit
      end
      
    rescue Net::SSH::Disconnect
      io.log "Could not connect to the server: Wrong IP or Server Offline."
      exit
    
    end
    
    def logs(app_name)
      begin
        connect
        ch = @conn.open_channel do |ssh|
          ch.exec "cd #{app_name}; tail -f log/production.log" do |ch, success|
            abort "Could not connect to rails app" unless success

            ch.on_data          { |ch, data| puts data}
            ch.on_extended_data { |ch, type, data| puts data }
          end

          @conn.loop
        end
        
        ch.wait
      rescue SystemExit, Interrupt
        puts ""
        puts ""
        puts "Logging done."
      rescue Exception => e
      end
    end
    
    def console(app_name)
      connect
      input = 'something'
      ch = @conn.open_channel do |ch|
        ch.request_pty do |ch, success|
          abort "Error requesting pty" unless success
        end

        ch.env "PATH", "/usr/bin:/usr/local/bin:/opt/ruby-enterprise/bin"
        ch.exec "cd #{app_name}; rails console production" do |ch, success|
          abort "Could not connect to rails console" unless success

          ch.on_data do |ch, data|
            next if data.chomp == input.chomp || data.chomp == ''
            if data =~ /^irb(.*)[\>|\*] /
              prompt = ''
              data.each_with_index do |s, i|
                if s =~ /^irb(.*)[\>|\*] /
                  prompt = s
                else
                  print s unless s.chomp == input.chomp
                end
              end

              # print data
              input = "#{Readline.readline(prompt, true)}\n" 
              ch.send_data(input) 
            else
              puts data
            end
          end

          ch.on_extended_data do |ch, type, data|
            puts data
          end
        end

        @conn.loop
      end
      
      ch.wait
    end
    
    def execute(script, echo=false, ret_exit_code=false)
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
      
      return exit_code if ret_exit_code
      output
    end
  end
end