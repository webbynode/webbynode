require 'rubygems'
require 'rake'  
require 'rake/testtask'

require 'echoe'  
  
Echoe.new('webbynode', '0.1.2') do |p|  
  p.description     = "Webbynode Deployment Gem"  
  p.url             = "http://webbynode.com"  
  p.author          = "Felipe Coury"
  p.email           = "felipe@webbynode.com"  
  p.ignore_pattern  = ["tmp/*", "script/*"]  
  p.dependencies = [ ['httparty', '>=0.4.5'] ]
  # p.dependencies = [
  #   ['activeresource','>= 2.3.4'],
  #   ['activesupport','>= 2.3.4'],
  #   ['rainbow', '>=1.0.4'],
  #   ['highline', '>=1.5.1'],
  #   ['httparty', '>=0.4.5']
  # ]
  p.install_message = <<EOS
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
         Webbynode deployment gem 
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  This deployment engine is highly experimental and
  should be considered beta code for the time being.

  Commands:

  	webbynode init		Initializes the current app for deployment to a Webby
  	webbynode push		Deploys the current committed code to a Webby

EOS
end
# 
# Rake::TestTask.new(:test_new) do |test|
#   test.libs << 'test'
#   test.ruby_opts << '-rubygems'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
# end

require 'rcov/rcovtask'
desc 'Measures test coverage using rcov'
namespace :rcov do
  desc 'Output unit test coverage of plugin.'
  Rcov::RcovTask.new(:unit) do |rcov|
    rcov.libs << 'test'
    rcov.ruby_opts << '-rubygems'
    rcov.pattern    = 'test/unit/**/test_*.rb'
    rcov.output_dir = 'rcov'
    rcov.verbose    = true
    rcov.rcov_opts << '--exclude "gems/*"'
  end
end
