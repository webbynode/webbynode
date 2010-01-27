Given /^I am running webbynode gem for the first time$/ do
end

When /^I run "([^\"]*)"$/ do |command_line|
  args = command_line.split(" ")
  args.shift
  
  @app = Webbynode::Application.new(*args)
  @app.execute
end

Then /^I should see "([^\"]*)"$/ do |output|
  stdout.should =~ /#{output}/
end