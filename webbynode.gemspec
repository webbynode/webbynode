# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{webbynode}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Felipe Coury"]
  s.date = %q{2010-01-26}
  s.description = %q{Webbynode Deployment Gem}
  s.email = %q{felipe@webbynode.com}
  s.executables = ["webbynode", "wn"]
  s.extra_rdoc_files = ["README.rdoc", "bin/webbynode", "bin/wn", "lib/templates/gitignore", "lib/templates/help", "lib/webbynode.rb", "lib/webbynode/api_client.rb", "lib/webbynode/application.rb", "lib/webbynode/command.rb", "lib/webbynode/commands.rb", "lib/webbynode/commands/add_key.rb", "lib/webbynode/commands/help.rb", "lib/webbynode/commands/init.rb", "lib/webbynode/commands/remote.rb", "lib/webbynode/commands/tasks.rb", "lib/webbynode/git.rb", "lib/webbynode/helpers.rb", "lib/webbynode/io.rb", "lib/webbynode/option.rb", "lib/webbynode/parameter.rb", "lib/webbynode/push_and.rb", "lib/webbynode/remote_executor.rb", "lib/webbynode/server.rb", "lib/webbynode/ssh.rb", "lib/webbynode/ssh_keys.rb"]
  s.files = ["History.txt", "Manifest", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/webbynode", "bin/wn", "devver.rake", "lib/templates/gitignore", "lib/templates/help", "lib/webbynode.rb", "lib/webbynode/api_client.rb", "lib/webbynode/application.rb", "lib/webbynode/command.rb", "lib/webbynode/commands.rb", "lib/webbynode/commands/add_key.rb", "lib/webbynode/commands/help.rb", "lib/webbynode/commands/init.rb", "lib/webbynode/commands/remote.rb", "lib/webbynode/commands/tasks.rb", "lib/webbynode/git.rb", "lib/webbynode/helpers.rb", "lib/webbynode/io.rb", "lib/webbynode/option.rb", "lib/webbynode/parameter.rb", "lib/webbynode/push_and.rb", "lib/webbynode/remote_executor.rb", "lib/webbynode/server.rb", "lib/webbynode/ssh.rb", "lib/webbynode/ssh_keys.rb", "spec/fixtures/api/credentials", "spec/fixtures/api/webbies", "spec/fixtures/commands/tasks/after_push", "spec/fixtures/fixture_helpers", "spec/fixtures/git/config/210.11.13.12", "spec/fixtures/git/config/67.23.79.31", "spec/fixtures/git/config/67.23.79.32", "spec/fixtures/git/config/config", "spec/fixtures/pushand", "spec/spec_helper.rb", "spec/webbynode/api_client_spec.rb", "spec/webbynode/application_spec.rb", "spec/webbynode/command_spec.rb", "spec/webbynode/commands/add_key_spec.rb", "spec/webbynode/commands/help_spec.rb", "spec/webbynode/commands/init_spec.rb", "spec/webbynode/commands/remote_spec.rb", "spec/webbynode/commands/tasks_spec.rb", "spec/webbynode/git_spec.rb", "spec/webbynode/io_spec.rb", "spec/webbynode/option_spec.rb", "spec/webbynode/parameter_spec.rb", "spec/webbynode/push_and_spec.rb", "spec/webbynode/remote_executor_spec.rb", "spec/webbynode/server_spec.rb", "webbynode.gemspec"]
  s.homepage = %q{http://webbynode.com}
  s.post_install_message = %q{  

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
      
}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Webbynode", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{webbynode}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Webbynode Deployment Gem}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.5"])
    else
      s.add_dependency(%q<httparty>, [">= 0.4.5"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.4.5"])
  end
end
