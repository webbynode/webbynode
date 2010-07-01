module Webbynode::Engines
  class Rails
    include Engine
    set_name "Rails 2"

    def detected?
      io.directory?('app') && io.directory?('app/controllers') &&
      io.file_exists?('config/environment.rb')
    end
  end
end