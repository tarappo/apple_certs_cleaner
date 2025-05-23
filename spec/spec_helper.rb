require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("support", __dir__)
require "apple_certs_info"
require "apple_certs_cleaner"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
