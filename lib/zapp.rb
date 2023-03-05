# frozen_string_literal: true

# External dependencies are loaded here
require("irb")
require("socket")
require("concurrent")
require("puma")
require("rack")

# Zapp is a web server for Rack-based Ruby 3.0.0+ applications
module Zapp
  class ZappError < StandardError; end

  class << self
    # The hash key in Ractor.current that stores the global Zapp::Configuration instance
    RACTOR_CONFIG_KEY = :ZAPP_CONFIG
    private_constant :RACTOR_CONFIG_KEY

    def config(reset: false)
      Ractor.current[RACTOR_CONFIG_KEY] = Zapp::Configuration.new if reset

      Ractor.current[RACTOR_CONFIG_KEY] ||= Zapp::Configuration.new
    end

    def __set_config(config)
      Ractor.current[RACTOR_CONFIG_KEY] = config
    end

    def configure
      yield(config)
    end
  end
end

require_relative("zapp/version")
require_relative("zapp/logger")
require_relative("zapp/configuration")
require_relative("zapp/input_stream")
require_relative("zapp/http_context/context")
require_relative("zapp/pipe")
require_relative("zapp/socket_pipe/sender")
require_relative("zapp/socket_pipe/receiver")
require_relative("zapp/worker")
require_relative("zapp/worker_pool")
require_relative("zapp/server")
require_relative("zapp/cli")
