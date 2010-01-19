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
  

  -=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-
        Webbynode Rapid Deployment Gem
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-

    This deployment engine is highly experimental and
    should be considered beta code for now.



    Initial Setup
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-

    Setup an initial Webbynode repository with:

      webbynode init [webby_ip] [example.com]
      * This will initialize git
      * This will add and commit what you currently have
      * This will add Webbynode to "git remote"

    Now, deploy your application with:

      webbynode push

    Then, for each update, follow the familiar git workflow:

      git add .
      git commit -m "My Updates"

    And finally, to release the updated version of your application, again, execute:

      webbynode push



    Webbynode Commands
  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-

    webbynode init [webby_ip] [example.com]
    * Initializes the Webbynode environment for your application  

    webbynode remote [command]
    * Run a command on the Webby from the applications' root
      example(s):
        webbynode remote 'rake my:custom:task'
        webbynode remote 'cat log/production.log'

    webbynode addkey
    * Adds your public SSH key to your Webby so you will no longer
      be prompted for your password when interacting with your Webby

    webbynode version
    * Displays the currently installed version of Webbynode gem
      
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
