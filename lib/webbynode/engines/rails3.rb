module Webbynode::Engines
  class Rails3
    include Engine
    set_name "Rails 3"

    def detected?
      io.file_exists?('script/rails')
    end
  end
end