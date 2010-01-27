Feature: Bootstrap an app for deployment
  In order to get the app online
  As a Webbynode user
  I want bootstrap my app
  
  Scenario: Running the init command with no params
    Given I am running webbynode gem for the first time
     When I run "wn init"
     Then I should see "Missing 'webby' parameter"
      And I should see "Usage: webbynode init webby \[dns\] \[options\]"

  Scenario: Getting help for the init command
    When I run "wn help init"
    Then I should see "Usage: webbynode init webby \[dns\] \[options\]"
     And I should see "Parameters:"
     And I should see "    webby                       Name or IP of the Webby to deploy to"
     And I should see "    dns                         The DNS used for this application, optional"
     And I should see "Options:"
     And I should see "    --passphrase=words          If present, passphrase will be used when creating a new SSH key"
