# frozen_string_literal: true

require "etc"
require "singleton"
require "ostruct"

module Zap
  # Class holding the configuration values used by Zap
  class Configuration
    attr_accessor :parallelism, :logger_class, :log_requests

    DEFAULT_OPTIONS = {
      # Default to number of CPUs available
      parallelism: Etc.nprocessors,

      # Default logging behavior
      logger_class: Zap::Logger,
      log_requests: true
    }.freeze

    def initialize
      DEFAULT_OPTIONS.each_key do |key|
        public_send("#{key}=", DEFAULT_OPTIONS[key])
      end
      @parallelism = DEFAULT_OPTIONS[:parallelism]
      @logger_class = DEFAULT_OPTIONS[:logger_class]
    end

    def configure
      yield(self)
    end
  end
end
