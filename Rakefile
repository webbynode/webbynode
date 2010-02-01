require 'rubygems'
require 'rake'  
require 'rake/testtask'

require 'echoe'  
  
Echoe.new('webbynode', '0.2.0') do |p|  
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
  

  -=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-
        Webbynode Rapid Deployment Gem
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-

    This deployment engine is highly experimental and
    should be considered beta code for now.


    Initial Setup
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-

    Setup an initial Webbynode repository with:

      webbynode init [webby_name OR webby_ip] [example.com]
      This will:
        * generate the .webbynode folder
        * generate the .pushand file
        * generate the .gitignore file
        * initialize git
        * add and commit what you currently have
        * add Webbynode to "git remote"

    Now, deploy your application with:

      webbynode push

    Then, for each update, follow the familiar git workflow:

      git add .
      git commit -m "My Updates"

    And finally, to release the updated version of your application, again, execute:

      webbynode push


    Webbynode Commands
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-

    For a list of available commands, run:
    
      webbynode help
    
    To get help on a specific command, run:
    
      webbynode help [command]
      
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
