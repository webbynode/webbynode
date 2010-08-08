require 'rubygems'
require 'rake'  
require 'rake/testtask'

require 'echoe'  
  
Echoe.new('webbynode', '1.0.2') do |p|  
  p.description     = "Webbynode Deployment Gem"  
  p.url             = "http://webbynode.com"  
  p.author          = "Felipe Coury"
  p.email           = "felipe@webbynode.com"  
  p.ignore_pattern  = ["tmp/*", "script/*"]  
  p.dependencies = [ 
    ['bundler', '>=0.9.26'],
    ['net-ssh', '>=2.0.20'],
    ['highline', '>=1.5.2'],
    ['httparty', '>=0.4.5'],
    ['launchy',  '>=0.3.7'],
    ['domainatrix','>=0.0.7'],
  ]
  # p.dependencies = [
  #   ['activeresource','>= 2.3.4'],
  #   ['activesupport','>= 2.3.4'],
  #   ['rainbow', '>=1.0.4'],
  #   ['highline', '>=1.5.1'],
  #   ['httparty', '>=0.4.5']
  # ]
  p.install_message = "
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      Webbynode Rapid Deployment Gem
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Thank you for installing Webbynode gem. You're now
able to deploy and manage your applications from
the comfort of your command line.

Please read our guide for a quickstart:
http://guides.webbynode.com/articles/rapidapps/

"
end

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
