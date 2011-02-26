module Webbynode::Engines
  All = [
    Webbynode::Engines::Html,
    Webbynode::Engines::Django,
    Webbynode::Engines::WSGI,
    Webbynode::Engines::Php,
    Webbynode::Engines::Rack,
    Webbynode::Engines::Rails,
    Webbynode::Engines::Rails3,
    Webbynode::Engines::NodeJS,
  ]

  Detectable = [
    # order matters!
    Webbynode::Engines::Rails3,
    Webbynode::Engines::Rails,
    Webbynode::Engines::Rack,
    Webbynode::Engines::NodeJS
  ]
end