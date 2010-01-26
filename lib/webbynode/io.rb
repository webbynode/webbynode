module Webbynode
  class Io
    class KeyAlreadyExists < StandardError; end
    
    TemplatesPath = File.join(File.dirname(__FILE__), '..', 'templates')
    
    def app_name
      Dir.pwd.split("/").last.gsub(/[\.| ]/, "_")
    end
    
    def exec(s)
      `#{s} 2>&1`
    end
    
    def directory?(s)
      File.directory?(s)
    end
    
    def file_exists?(f)
      File.exists?(f)
    end
    
    def read_file(f)
      File.read(f)
    end
    
    def open_file(f, a)
      File.open(f, a)
    end
    
    def log(text)
      puts text
    end

    def log_and_exit(text)
      puts text
      exit
    end
    
    def create_local_key(passphrase="")
      unless File.exists?(Webbynode::Commands::AddKey::LocalSshKey)
        exec "ssh-keygen -t rsa -N \"#{passphrase}\" -f #{Webbynode::Commands::AddKey::LocalSshKey}"
      end
    end
    
    def create_file(file, contents)
      File.open(file, "w") do |file|
        file.write(contents)
      end
    end
    
    def templates_path
      TemplatesPath
    end
    
    def read_from_template(template)
      read_file File.join(templates_path, template)
    end
    
    def create_from_template(file, template)
      contents = read_from_template(template)
      create_file(file, contents)
    end
  end
end