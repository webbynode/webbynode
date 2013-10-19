require "bundler"

module Webbynode::Engines
  class Rails4
    include Engine
    set_name "Rails 4"
    git_excludes "config/database.yml" #, "db/schema.rb"

    def detected?
      return unless io.file_exists?('Gemfile') && io.file_exists?('Gemfile.lock')
      bundler = Bundler::LockfileParser.new(File.read("Gemfile.lock"))
      rails_version = bundler.specs.detect { |g| g.name == "railties" }.version
      rails_version >= Gem::Version.new('4.0.0.beta') && rails_version < Gem::Version.new('5.0.0') if rails_version
    end

    def prepare
      check_gemfile
      super
    end

    private

    def handle_adapter
      if io.file_exists?("config/database.yml")
        contents = io.read_file("config/database.yml")
        if contents =~ /mysql2/
          io.add_setting "rails3_adapter", "mysql2"
          return
        end
      end

      io.remove_setting "rails3_adapter"
    end

    def check_gemfile
      return unless gemfile.present?

      handle_adapter

      dependencies = gemfile.dependencies(:without => [:development, :test])
      if dependencies.include? 'sqlite3-ruby'
        raise Webbynode::Command::CommandError, <<-EOS

Gemfile dependency problem.

The following gem dependency was found in your Gemfile:

  gem 'sqlite3-ruby', :require => 'sqlite3'

This dependency will cause an error in production when using Passenger. We recommend you remove it.
Also, be sure to define the database driver gem for the database type you are using in production (either the mysql or the pg gem).

  gem 'mysql'

  -or-

  gem 'pg'

If you would like to use SQLite3 in your development and test environments,
you may do so by wrapping the gem definition inside the :test and :development groups.

  group :test do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end

  -or-

  group :development do
    gem 'sqlite3-ruby', :require => 'sqlite3'
  end

To learn more about this issue, visit:

  http://guides.webbynode.com/articles/rapidapps/rails3warning.html

EOS
      end
    end

  end
end
