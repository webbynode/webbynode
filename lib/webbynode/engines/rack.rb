module Webbynode::Engines
  class Rack
    include Engine
    set_name "Rack"

    def detected?
      io.file_exists?('config.ru')
    end
  end
end