# Zap

Zap is an experimental web server for Rack-based Ruby applications. It is based on the lightning fast [Puma](https://puma.io/) HTTP parser implemented in C,
and the new parallelism implementation introduced with CRuby 3.0.0, [Ractors](https://github.com/ruby/ruby/blob/master/doc/ractor.md)

This is an experimental project as Ractors are very very new and the Ractor API may change at any moment. While I would not recommend using this server in production for that reason,
if you do decide to do so, pin your ruby version to one of the versions this project is tested against.

## TODO

* Add way more tests to all parts of the library
* Add CLI handler for Rack applications (config.ru)
* Add some benchmarks against Puma, quite interesting to see how Ractors perform
