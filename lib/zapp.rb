# frozen_string_literal: true

# External dependencies are loaded here
require("socket")
require("concurrent")
require("puma")
require("rack")

# Zapp is a web server for Rack-based Ruby 3.0.0+ applications
module Zapp
  class ZappError < StandardError; end

  class << self
    def config(reset: false)
      @config = Zapp::Configuration.new if reset

      @config ||= Zapp::Configuration.new
    end

    def configure
      yield(config)
    end
  end
end

require("zapp/version")
require("zapp/logger")
require("zapp/configuration")
require("zapp/input_stream")
require("zapp/http_context/context")
require("zapp/worker")
require("zapp/worker_pool")
require("zapp/server")
require("zapp/cli")
