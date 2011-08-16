module Webbynode
  class PushAndError < StandardError; end
  class PushAndFileNotFound < StandardError; end

  class PushAnd
    def io; @io ||= Webbynode::Io.new; end
    
    def present?
      io.file_exists?(".pushand")
    end
    
    def parse_remote_app_name
      io.read_file(".pushand")[/^phd \$0 ([^ ]+)/, 1]
    end

    def remote_db_name
      parse_remote_app_name.gsub(/[-._]/, "")      
    end
    
    def create!(app_name, dns_entry)
      io.create_file(".pushand", "#! /bin/bash\nphd $0 #{app_name} #{dns_entry}\n", true)
    end
  end
end
