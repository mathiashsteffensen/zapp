# Zapp

Zapp is an experimental web server for Rack-based Ruby applications. It is based on the lightning fast [Puma](https://puma.io/) HTTP parser implemented in C,
and the new parallelism implementation introduced with CRuby 3.0.0, [Ractors](https://github.com/ruby/ruby/blob/master/doc/ractor.md)

This is an experimental project as Ractors are very very new and the Ractor API may change at any moment. While I would not recommend using this server in production for that reason,
if you do decide to do so, pin your ruby version to one of the versions this project is tested against (Currently only version 3.0.0).

Why is it named Zapp with 2 p's you may ask? Because Zap with 1 p was taken.

Also it's meant to be pretty fast

## Installation

As a stand-alone ruby executable
```bash
gem install zapp
```

Or using Bundler, add the following to your gemfile
```ruby
gem("zapp")
```

And then run
```bash
bundle
```

## Usage

The CLI tool is meant to be dead simple, and all configuration should be done through a configuration file.
By default Zapp will look for a config file located at ./config/zapp.rb from where the command is run.
To change this you can provide the optional -c flag when running the command.

To use a config file at ./configuration/server.rb:
```bash
bundle exec zapp -c ./configuration/server.rb
```

An example config file using Zapp's DSL may look like the following
```ruby
# frozen_string_literal: true

# A simple web server
class App
  def self.call(_env)
    [200, {}, ["Hello from Zapp"]]
  end
end

# Register the app
app(App)

# Launch 2 parallel Zapp workers
parallelism(2)

# Have Zapp be quiet
# (by default Zapp workers time requests and log when they have been processed)
log_requests(false)

# Let's bind to 0.0.0.0 instead of localhost
# since we may run the server from a Docker container
host("0.0.0.0")

# Use port 8080 (3000 is the default)
port(8080)
```

Run the app
```bash
bundle exec zapp
```

## Implementation details

* Parsing is done in a single thread
  * Puma's HTTP Parser can not be shared between Ractors, and it cannot be copied to a Ractor so parsing can be done in parallel, I have a suspicion this is due to it being a C extension. 
    If you have any suggestions for how to implement parallel parsing, please file a PR or an issue.
* Request processing is done in parallel using the Ractor API

## TODO

* Add way more tests to all parts of the library
* Resolve Rails/Ractor compatibility issues
* Add thread pool per worker
* Add some benchmarks against Puma, quite interesting to see how Ractors perform
* PID file support
* Support for rack_options
