module Webbynode
  class Io
    def app_name
      Dir.pwd.split("/").last.gsub(/[\.| ]/, "_")
    end
    
    def exec(s)
      `#{s}`
    end
    
    def directory?(s)
      File.directory?(s)
    end
    
    def read_file(f)
      File.read(f)
    end
  end
end