# frozen_string_literal: true

# External dependencies are loaded here
require("socket")
require("puma")
require("rack")

# Zap is a web server for Rack-based Ruby 3.0.0+ applications
module Zap
  class ZapError < StandardError; end

  def self.config
    @config ||= Zap::Configuration.new
  end

  def self.configure(&block)
    config.configure(&block)
  end
end

require("zap/version")
require("zap/logger")
require("zap/configuration")
require("zap/input_stream")
require("zap/worker")
require("zap/worker_pool")
require("zap/request")
require("zap/server")
