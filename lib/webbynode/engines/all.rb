module Webbynode::Engines
  All = [
    Webbynode::Engines::Django,
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
    Webbynode::Engines::Rack
  ]
end