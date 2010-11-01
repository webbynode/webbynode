module Webbynode::Engines
  class Rails
    include Engine
    set_name "Rails 2"
    git_excludes "config/database.yml" #, "db/schema.rb"

    def detected?
      io.directory?('app') && io.directory?('app/controllers') &&
      io.file_exists?('config/environment.rb')
    end
  end
end