require 'rake'

namespace :devver do

  APP_CALL = 'devver'
  # List any test files you do not want to run on Devver. This array can contain names and regular expressions. 
  EXCLUDED_TEST_FILES = []

  desc "Runs all units functionals and integration tests on Devver"
  task :test do
    errors = %w(devver:test:units devver:test:functionals devver:test:integration).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.join(", ").to_s}!" if errors.any?
  end

  desc "Forces Devver to clear and rebuild the database (by executing the 'prepare_database' hook)"
  task :prepare_db do
    command = "#{APP_CALL} --db"
    puts command
    system(command)
  end

  desc "Forces Devver to try to install dependencies (by executing the 'install_dependencies' hook)"
  task :install_dependencies do
    command = "#{APP_CALL} --install_dependencies"
    puts command
    system(command)
  end

  desc "Forces Devver to sync all changed files"
  task :sync do
    command = "#{APP_CALL} --sync"
    puts command
    system(command)
  end
  
  desc "Delete the Devver project ID for this project. The next time you connect to Devver, you'll be assigned a new project ID"
  task :reset do
    command = "rm .devver/project_id"
    system(command)
    puts "Your project has been reset successfully"
  end
  
  desc "Delete all of the project files on the server and resync"
  task :reload do
    command = "#{APP_CALL} --reload"
    puts command
    system(command)
  end

  desc "Runs all specs on Devver"
  task :spec do
    devvertest('spec/**/*_spec.rb')
  end

  namespace :spec do
    desc "Runs all model specs on Devver"
    task :model do
      devvertest('spec/models/**/*_spec.rb')
    end

    desc "Runs all request specs on Devver"
    task :request do
      devvertest('spec/requests/**/*_spec.rb')
    end

    desc "Runs all controller specs on Devver"
    task :controller do
      devvertest('spec/controllers/**/*_spec.rb')
    end

    desc "Runs all view specs on Devver"
    task :view do
      devvertest('spec/views/**/*_spec.rb')
    end

    desc "Runs all helper specs on Devver"
    task :helper do
      devvertest('spec/helpers/**/*_spec.rb')
    end

    desc "Runs all lib specs on Devver"
    task :lib do
      devvertest('spec/lib/**/*_spec.rb')
    end

  end


  namespace :test do
    desc "Runs all unit tests on Devver"
    task :units do
      devvertest('test/unit/**/*_test.rb')
    end

    desc "Runs all functional tests on Devver"
    task :functionals do
      devvertest('test/functional/**/*_test.rb')
    end

    desc "Runs all integration tests on Devver"
    task :integration do
      devvertest('test/integration/**/*_test.rb')
    end

  end
end

def remove_excluded_files(files)
  removed_files = []
  files.each do |file|
    EXCLUDED_TEST_FILES.each do |exclude|
      removed_files << file if exclude===file
    end
  end
  removed_files = removed_files.flatten
  files = files - removed_files
  [files, removed_files]
end

def run_tests_locally(files)
  puts "Running the excluded test files locally"
  # Run RSpec files
  if files.first=~/_spec.rb/
    command ="spec "
  else # Run Test::Unit files
    command = 'ruby -e "ARGV.each{|f| load f unless f =~ /^-/}" '
  end
  command += files.join(" ")
  puts command
  results = system(command)
  raise RuntimeError.new("Command failed with status (1)") unless results
end

def get_env_var(var_name)
  ENV[var_name] || ENV[var_name.upcase]
end

def devvertest(pattern)
  reload = get_env_var('reload')=='true' ? true : false
  #default sync to true
  sync = true 
  sync = false if get_env_var('sync')=='false' 
  cache = get_env_var('cache')=='true' ? true : false
  db = get_env_var('db')=='true' ? true : false
  run_excluded = get_env_var('run_excluded')
  if run_excluded=='true' || run_excluded=='after'
    run_excluded = 'after' 
  elsif run_excluded=='only'
    run_excluded = 'only'
  else
    run_excluded = ''
  end

  files = FileList[pattern].to_a
  files, removed_files = remove_excluded_files(files)

  if run_excluded!='only'
    command = "#{APP_CALL} #{'--reload' if reload} #{'--nosync' if !sync} #{'--db' if db} #{'--cache' if cache} #{files.join(' ')}"
    puts command
    results = system(command)
    raise RuntimeError.new("Command failed with status (1)") unless results
  end
  
  if run_excluded=='only' || run_excluded=='after'  
    run_tests_locally(removed_files) if removed_files.length > 0
  end
end
