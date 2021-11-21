# frozen_string_literal: true

require_relative("lib/zap/version")

Gem::Specification.new do |spec|
  spec.name          = "zap"
  spec.version       = Zap::VERSION
  spec.authors       = ["Mathias H Steffensen"]
  spec.email         = ["mathiashsteffensen@protonmail.com"]

  spec.summary       = "A Web Server based on Ractors, for Rack-based Ruby applications"
  spec.homepage      = "https://github.com/mathiashsteffensen/zap"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mathiashsteffensen/zap"
  spec.metadata["changelog_uri"] = "https://github.com/mathiashsteffensen/zap/blob/master/CHANGELOG.md"

  # Which files should be added to the gem when it is released.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:spec|example)/}) }
    end
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  # This is of course a web server for Rack applications
  spec.add_dependency("rack", "~> 2.2.3")

  # Use Puma's C-based HttpParser, it's fast as hell
  spec.add_dependency("puma", "~> 5.5.2")

  # Concurrent ruby for managing Thread pools
  spec.add_dependency("concurrent-ruby", "~> 1.1.9")

  # Rake for task running
  spec.add_dependency("rake", "~> 13.0")

  # RSpec for testing
  spec.add_dependency("rspec", "~> 3.0")
end
