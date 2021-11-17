# frozen_string_literal: true

# External dependencies are loaded here
require("socket")
require("puma")
require("rack")

# Zap is a web server for Rack-based Ruby 3.0.0+ applications
module Zap
  class ZapError < StandardError; end

  class << self
    def config
      @config ||= Zap::Configuration.new
    end

    def configure
      yield(config)
    end
  end
end

require("zap/version")
require("zap/logger")
require("zap/configuration")
require("zap/input_stream")
require("zap/http_context/context")
require("zap/worker")
require("zap/worker_pool")
require("zap/request")
require("zap/server")
