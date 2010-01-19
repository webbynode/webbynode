module Wn
  module Helpers
  
    attr_accessor :remote_ip, :remote_app_name
  
    # Tests if specified directory exist
    def dir_exists(dir)
      File.directory?(dir)
    end
  
    # Alias for printing to command line
    def log(text)
      puts text
    end
    
    # Alias for log and also exists the program
    def log_and_exit(text)
      puts text
      exit
    end
  
    # Tests to see if the specified file exists
    def file_exists(file)
      File.exists?(file)
    end
  
    # Creates a file to the specified path
    # Writes specified content to it
    def create_file(filename, contents)
      File.open(filename, "w") do |file|
        file.write(contents)
      end
    end
  
    # Alias for executing a command
    # Raises an exception when in test environment
    def run(command)
      log_and_exit "Tried to run: #{command}" if $testing
      %x(#{command})
    end
    
    # Runs and returned a "chomped" version of the output
    def run_and_return(command)
      log_and_exit "Tried to run: #{command}" if $testing
      %x(#{command}).chomp
    end
    
    # Returns the based on the folder name
    # Removes characters that will cause issues
    def app_name
      Dir.pwd.split("/").last.gsub(/\./, "_")
    end
    
    # Returns the full path to the template folder
    def templates_path
      File.join(File.dirname(__FILE__), '..', 'templates')
    end
    
    # Reads a file from the template folder
    def read_template(template)
      File.open(File.join(templates_path, template), 'r').read
    end
    
    # Parses the given file (would assumingly only be for .git/config files)
    # It returns/generates a hash containing the configuration for each remote
    # Webbynode will be particularly interesseted in the @config["remote"]["webbynode"] hash/key
    def parse_configuration(file)
      config = {}
      current = nil
      File.open(file).each_line do |line|
        case line
        when /^\[(\w+)(?: "(.+)")*\]/
          key, subkey = $1, $2
          current = (config[key] ||= {})
          current = (current[subkey] ||= {}) if subkey
        else
          key, value = line.strip.split(' = ')
          current[key] = value
        end
      end
      config
    end
    
    # Parses the given file (the .pushand) and extracts the remote application name/folder
    def parse_pushand(file)
      File.open(file).each_line do |line|
        case line
        when /^phd \$0 (.+)$/
          return $1
        end
      end
    end
    
    # Parses the remote IP that's stored inside the .git/config file
    # Will only parse it once. Any other requests will be pulled from memory
    # The remote IP will be stored inside the @remote_ip instance variable
    def parse_remote_ip
      @config     ||= parse_configuration(".git/config")
      @remote_ip  ||= $2 if @config["remote"]["webbynode"]["url"] =~ /^(\w+)@(.+):(.+)$/
    end
    
    # Parses the remote app name that's stored inside the .pushand file
    # Will only parse it once. Any other requests will be pulled from memory
    # The remote app name will be stored inside the @remote_ip instance variable
    def parse_remote_app_name
      @remote_app_name ||= parse_pushand(".pushand")
    end
    
    # Attempts to connect to the Webby without a password
    # if this failed, it will re-attempt and prompt the user for the password for the "git" user
    def run_remote_command(command)
      # Finds the remote ip and stores it in "remote_ip"
      parse_remote_ip
      
      # Finds the remote ip and stores it in "remote_app_name"
      parse_remote_app_name
      
      begin
        remote_command(command)
      rescue Net::SSH::AuthenticationFailed
        HighLine.track_eof  = false
        password            = ask("Enter your password: ") { |q| q.echo = '' }
        remote_command(command, password)
      end
    end
    
    private
 
    # Will attempt to run a command on the Webby (inside the application root)
    # This must only be initialized through "run_remote_command(command)" to ensure
    # password prompt if this is required by the Webby
    def remote_command(command, password = nil)
      Net::SSH.start(remote_ip, 'git', :password => password) do |ssh|
        ssh.exec("cd #{remote_app_name} && #{command}")
      end  
    end
  end
end