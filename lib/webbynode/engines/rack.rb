module Webbynode::Engines
  class Rack
    include Engine

    def detected?
      io.file_exists?('config.ru')
    end
  end
end