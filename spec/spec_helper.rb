# frozen_string_literal: true

require("simplecov")

SimpleCov.start do
  add_filter("/spec/")
  add_filter("/vendor/")
  add_filter("/example/")

  add_group("Zapp", "lib/zapp")
  add_group("HTTPContext", "lib/zapp/http_context")
end

require("zapp")

Dir.glob("spec/support/*.rb") { |f| require_relative(f.gsub("spec", ".")) }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.before do
    Zapp.config(reset: true)

    Zapp::Logger.level = Zapp::Logger::LEVELS[:WARN]
    Zapp.configure do |c|
      c.parallelism = 1
      c.log_requests = false
      c.log_uncaught_errors = true
    end
  end
end
