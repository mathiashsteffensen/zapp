# frozen_string_literal: true

# External dependencies are loaded here
require("socket")
require("puma")

module Zap
  class ZapError < StandardError; end
end

require("zap/version")
require("zap/logger")
require("zap/input_stream")
require("zap/worker_pool")
require("zap/request")
require("zap/server")
