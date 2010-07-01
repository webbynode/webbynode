# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{webbynode}
  s.version = "0.2.5.beta1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Felipe Coury"]
  s.date = %q{2010-06-30}
  s.description = %q{Webbynode Deployment Gem}
  s.email = %q{felipe@webbynode.com}
  s.executables = ["webbynode", "wn"]
  s.extra_rdoc_files = ["README.rdoc", "bin/webbynode", "bin/wn", "lib/templates/api_token", "lib/templates/backup", "lib/templates/gitignore", "lib/templates/help", "lib/webbynode.rb", "lib/webbynode/api_client.rb", "lib/webbynode/application.rb", "lib/webbynode/command.rb", "lib/webbynode/commands/add_backup.rb", "lib/webbynode/commands/add_key.rb", "lib/webbynode/commands/alias.rb", "lib/webbynode/commands/apps.rb", "lib/webbynode/commands/change_dns.rb", "lib/webbynode/commands/config.rb", "lib/webbynode/commands/delete.rb", "lib/webbynode/commands/help.rb", "lib/webbynode/commands/init.rb", "lib/webbynode/commands/push.rb", "lib/webbynode/commands/remote.rb", "lib/webbynode/commands/restart.rb", "lib/webbynode/commands/start.rb", "lib/webbynode/commands/stop.rb", "lib/webbynode/commands/tasks.rb", "lib/webbynode/commands/version.rb", "lib/webbynode/commands/webbies.rb", "lib/webbynode/engines/all.rb", "lib/webbynode/engines/django.rb", "lib/webbynode/engines/engine.rb", "lib/webbynode/engines/php.rb", "lib/webbynode/engines/rack.rb", "lib/webbynode/engines/rails.rb", "lib/webbynode/engines/rails3.rb", "lib/webbynode/gemfile.rb", "lib/webbynode/git.rb", "lib/webbynode/io.rb", "lib/webbynode/notify.rb", "lib/webbynode/option.rb", "lib/webbynode/parameter.rb", "lib/webbynode/properties.rb", "lib/webbynode/push_and.rb", "lib/webbynode/remote_executor.rb", "lib/webbynode/server.rb", "lib/webbynode/ssh.rb", "lib/webbynode/ssh_keys.rb", "lib/webbynode/updater.rb"]
  s.files = ["History.txt", "Manifest", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "assets/webbynode.png", "bin/webbynode", "bin/wn", "changelog.rdoc", "cucumber.yml.old", "devver.rake", "inactive_features/bootstrap.feature", "inactive_features/step_definitions/command_steps.rb", "inactive_features/support/env.rb", "inactive_features/support/hooks.rb", "inactive_features/support/io_features.rb", "inactive_features/support/mocha.rb", "lib/templates/api_token", "lib/templates/backup", "lib/templates/gitignore", "lib/templates/help", "lib/webbynode.rb", "lib/webbynode/api_client.rb", "lib/webbynode/application.rb", "lib/webbynode/command.rb", "lib/webbynode/commands/add_backup.rb", "lib/webbynode/commands/add_key.rb", "lib/webbynode/commands/alias.rb", "lib/webbynode/commands/apps.rb", "lib/webbynode/commands/change_dns.rb", "lib/webbynode/commands/config.rb", "lib/webbynode/commands/delete.rb", "lib/webbynode/commands/help.rb", "lib/webbynode/commands/init.rb", "lib/webbynode/commands/push.rb", "lib/webbynode/commands/remote.rb", "lib/webbynode/commands/restart.rb", "lib/webbynode/commands/start.rb", "lib/webbynode/commands/stop.rb", "lib/webbynode/commands/tasks.rb", "lib/webbynode/commands/version.rb", "lib/webbynode/commands/webbies.rb", "lib/webbynode/engines/all.rb", "lib/webbynode/engines/django.rb", "lib/webbynode/engines/engine.rb", "lib/webbynode/engines/php.rb", "lib/webbynode/engines/rack.rb", "lib/webbynode/engines/rails.rb", "lib/webbynode/engines/rails3.rb", "lib/webbynode/gemfile.rb", "lib/webbynode/git.rb", "lib/webbynode/io.rb", "lib/webbynode/notify.rb", "lib/webbynode/option.rb", "lib/webbynode/parameter.rb", "lib/webbynode/properties.rb", "lib/webbynode/push_and.rb", "lib/webbynode/remote_executor.rb", "lib/webbynode/server.rb", "lib/webbynode/ssh.rb", "lib/webbynode/ssh_keys.rb", "lib/webbynode/updater.rb", "spec/fixtures/aliases", "spec/fixtures/api/credentials", "spec/fixtures/api/dns", "spec/fixtures/api/dns_a_record", "spec/fixtures/api/dns_a_record_already_exists", "spec/fixtures/api/dns_a_record_error", "spec/fixtures/api/dns_new_zone", "spec/fixtures/api/webbies", "spec/fixtures/api/webbies_unauthorized", "spec/fixtures/api/webby", "spec/fixtures/commands/tasks/after_push", "spec/fixtures/fixture_helpers", "spec/fixtures/git/config/210.11.13.12", "spec/fixtures/git/config/67.23.79.31", "spec/fixtures/git/config/67.23.79.32", "spec/fixtures/git/config/config", "spec/fixtures/git/config/config_5", "spec/fixtures/git/status/clean", "spec/fixtures/git/status/dirty", "spec/fixtures/pushand", "spec/spec_helper.rb", "spec/webbynode/api_client_spec.rb", "spec/webbynode/application_spec.rb", "spec/webbynode/command_spec.rb", "spec/webbynode/commands/add_backup_spec.rb", "spec/webbynode/commands/add_key_spec.rb", "spec/webbynode/commands/alias_spec.rb", "spec/webbynode/commands/apps_spec.rb", "spec/webbynode/commands/change_dns_spec.rb", "spec/webbynode/commands/config_spec.rb", "spec/webbynode/commands/delete_spec.rb", "spec/webbynode/commands/help_spec.rb", "spec/webbynode/commands/init_spec.rb", "spec/webbynode/commands/push_spec.rb", "spec/webbynode/commands/remote_spec.rb", "spec/webbynode/commands/tasks_spec.rb", "spec/webbynode/commands/version_spec.rb", "spec/webbynode/commands/webbies_spec.rb", "spec/webbynode/engines/django_spec.rb", "spec/webbynode/engines/php_spec.rb", "spec/webbynode/engines/rack_spec.rb", "spec/webbynode/engines/rails3_spec.rb", "spec/webbynode/engines/rails_spec.rb", "spec/webbynode/gemfile_spec.rb", "spec/webbynode/git_spec.rb", "spec/webbynode/io_spec.rb", "spec/webbynode/option_spec.rb", "spec/webbynode/parameter_spec.rb", "spec/webbynode/push_and_spec.rb", "spec/webbynode/remote_executor_spec.rb", "spec/webbynode/server_spec.rb", "webbynode.gemspec"]
  s.homepage = %q{http://webbynode.com}
  s.post_install_message = %q{
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      Webbynode Rapid Deployment Gem
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

This deployment engine is highly experimental and
should be considered beta code for now.

For a quickstart:
http://guides.webbynode.com/articles/rapidapps

}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Webbynode", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{webbynode}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Webbynode Deployment Gem}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bundler>, [">= 0.9.26"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.20"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5.2"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.5"])
      s.add_runtime_dependency(%q<domainatrix>, [">= 0.0.7"])
    else
      s.add_dependency(%q<bundler>, [">= 0.9.26"])
      s.add_dependency(%q<net-ssh>, [">= 2.0.20"])
      s.add_dependency(%q<highline>, [">= 1.5.2"])
      s.add_dependency(%q<httparty>, [">= 0.4.5"])
      s.add_dependency(%q<domainatrix>, [">= 0.0.7"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 0.9.26"])
    s.add_dependency(%q<net-ssh>, [">= 2.0.20"])
    s.add_dependency(%q<highline>, [">= 1.5.2"])
    s.add_dependency(%q<httparty>, [">= 0.4.5"])
    s.add_dependency(%q<domainatrix>, [">= 0.0.7"])
  end
end
