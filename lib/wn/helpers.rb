module Wn
  module Helpers
  
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
    
  end
end