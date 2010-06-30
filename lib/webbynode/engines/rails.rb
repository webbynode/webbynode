module Webbynode::Engines
  class Rails
    include Engine

    def detected?
      io.directory?('app') && io.directory?('app/controllers') &&
      io.file_exists?('config/environment.rb')
    end
  end
end