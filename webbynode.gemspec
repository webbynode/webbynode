# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "webbynode/version"

Gem::Specification.new do |s|
  s.name        = "webbynode"
  s.version     = Webbynode::Version::STRING
  s.authors     = ["Felipe Coury"]
  s.email       = ["felipe.coury@gmail.com"]
  s.homepage    = "http://webbynode.com"
  s.summary     = "Webbynode rapid application deployment tool"
  s.description = s.summary

  s.add_dependency "domainatrix"                  , "~> 0.0.7"
  s.add_dependency "highline"                     , "~> 1.6.1"
  s.add_dependency "httparty"                     , "~> 0.7.4"
  s.add_dependency "net-ssh"                      , "~> 2.1.0"
  s.add_dependency "sqlite3"                      , "~> 1.3.4"
  s.add_dependency "taps"                         , "~> 0.3.23"
  s.add_dependency "webbynode-rainbow"            , "~> 1.1.3"
  s.add_development_dependency "autotest-growl"   , "~> 0.2.9"
  s.add_development_dependency "awesome_print"    , "~> 0.3.2"
  s.add_development_dependency "fakeweb"          , "~> 1.3.0"
  s.add_development_dependency "guard"            , "~> 0.3.0"
  s.add_development_dependency "guard-rspec"      , "~> 0.1.9"
  s.add_development_dependency "rb-fsevent"       , "~> 0.9.2"
  s.add_development_dependency "rake"             , "~> 10.0.2"
  s.add_development_dependency "rcov"             , "~> 0.9.9"
  s.add_development_dependency "rspec"            , "~> 2.12.0"
  s.add_development_dependency "ZenTest"          , "~> 4.5.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
