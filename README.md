# Zap

Zap is an experimental web server for Rack-based Ruby applications. It is based on the lightning fast [Puma](https://puma.io/) HTTP parser implemented in C,
and the new parallelism implementation introduced with CRuby 3.0.0, [Ractors](https://github.com/ruby/ruby/blob/master/doc/ractor.md)

This is an experimental project as Ractors are very very new and the Ractor API may change at any moment. While I would not recommend using this server in production for that reason,
if you do decide to do so, pin your ruby version to one of the versions this project is tested against.

## Implementation details

* Parsing is done in a single thread
  * Puma's HTTP Parser can not be shared between Ractors, and it cannot be copied to a Ractor so parsing can be done in parallel, I have a suspicion this is due to it being a C extension. 
    If you have any suggestions for how to implement parallel parsing, please file a PR or an issue.
* Request processing is done both in parallel and concurrently

## TODO

* Add way more tests to all parts of the library
* Resolve Rails/Ractor compatibility issues
* Add thread pool per worker
* Add some benchmarks against Puma, quite interesting to see how Ractors perform
* PID file support
* Support for rack_options
