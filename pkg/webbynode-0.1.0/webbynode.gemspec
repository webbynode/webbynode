# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{webbynode}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Felipe Coury"]
  s.date = %q{2010-01-10}
  s.default_executable = %q{webbynode}
  s.description = %q{Webbynode Deployment Gem}
  s.email = %q{felipe@webbynode.com}
  s.executables = ["webbynode"]
  s.extra_rdoc_files = ["README.rdoc", "bin/webbynode", "lib/wn.rb"]
  s.files = ["History.txt", "Manifest", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/webbynode", "lib/wn.rb", "oldRakefile", "test/test_helper.rb", "test/test_webbynode.rb", "test/test_wn.rb", "webbynode.gemspec"]
  s.homepage = %q{http://webbynode.com}
  s.post_install_message = %q{  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
         Webbynode deployment gem 
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  This deployment engine is highly experimental and
  should be considered beta code for the time being.

  Commands:

  	webbynode init		Initializes the current app for deployment to a Webby
  	webbynode push		Deploys the current committed code to a Webby

}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Webbynode", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{webbynode}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Webbynode Deployment Gem}
  s.test_files = ["test/test_helper.rb", "test/test_webbynode.rb", "test/test_wn.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
