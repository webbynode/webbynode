module Webbynode::Engines
  class Rails3
    include Engine

    def detected?
      io.file_exists?('script/rails')
    end
  end
end