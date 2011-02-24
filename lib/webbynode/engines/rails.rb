module Webbynode::Engines
  class Rails
    include Engine
    set_name "Rails 2"
    git_excludes "config/database.yml" #, "db/schema.rb"

    def detected?
      io.directory?('app') && io.directory?('app/controllers') &&
      io.file_exists?('config/environment.rb')
    end
    
    def prepare
      contents = io.read_file("config/database.yml")
      if contents =~ /mysql2/
        io.add_setting "rails_adapter", "mysql2"
      else
        io.remove_setting "rails_adapter"
      end
    end
  end
end