# Require RSpec
require 'spec'

# Set Testing Environment
$testing = true


# Helper Methods

# Reads out a file from the fixtures directory
def read_fixture(file)
  File.read(File.join(File.dirname(__FILE__), "fixtures", file))
end

Webbynode = Wn