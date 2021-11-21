# frozen_string_literal: true

require("etc")
require("singleton")
require("ostruct")

module Zap
  # Class holding the configuration values used by Zap
  class Configuration
    attr_writer(
      :rackup_file,
      :parallelism,
      :threads_per_worker,
      :logger_class,
      :log_requests,
      :log_uncaught_errors,
      :host,
      :port,
      :app
    )

    attr_accessor(:env, :mode)

    DEFAULT_OPTIONS = {
      # Rack up file to use
      rackup_file: "config.ru",

      # Default to number of CPUs available
      # This is the amount of workers to run processing requests
      parallelism: Etc.nprocessors,
      # Number of Thread's to run within each worker
      threads_per_worker: 5,

      # Default logging behavior
      logger_class: Zap::Logger,
      log_requests: true,
      log_uncaught_errors: true,

      host: "localhost",
      port: 3000,

      mode: ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development",
      env: ENV.to_hash.merge(
        {
          Rack::RACK_VERSION => Rack::VERSION,
          Rack::RACK_ERRORS => $stderr,
          Rack::RACK_MULTITHREAD => false,
          Rack::RACK_MULTIPROCESS => true,
          Rack::RACK_RUNONCE => false,
          Rack::RACK_URL_SCHEME => %w[yes on 1].include?(ENV["HTTPS"]) ? "https" : "http"
        }
      )
    }.freeze

    def initialize
      DEFAULT_OPTIONS.each_key do |key|
        public_send("#{key}=", DEFAULT_OPTIONS[key])
      end
    end

    def rack_builder
      @rack_builder ||= begin
        require("rack")
        require("rack/builder")
        Rack::Builder
      rescue LoadError => e
        Zap::Logger.error("Failed to load Rack #{e}")
      end
    end

    def app(new = nil)
      @app = new unless new.nil?

      @app ||= begin
        raise(Zap::ZapError, "Missing rackup file '#{rackup_file}'") unless File.exist?(rackup_file)

        rack_app, = rack_builder.parse_file(rackup_file)

        rack_app
      end
    end

    def parallelism(new = nil)
      return @parallelism if new.nil?

      @parallelism = new
    end

    def threads_per_worker(new = nil)
      return @threads_per_worker if new.nil?

      @threads_per_worker = new
    end

    def logger_class(new = nil)
      return @logger_class if new.nil?

      @logger_class = new
    end

    def log_requests(new = nil)
      return @log_requests if new.nil?

      @log_requests = new
    end

    def log_uncaught_errors(new = nil)
      return @log_uncaught_errors if new.nil?

      @log_uncaught_errors = new
    end

    def host(new = nil)
      return @host if new.nil?

      @host = new
    end

    def port(new = nil)
      return @port if new.nil?

      @port = new
    end

    def rackup_file(new = nil)
      return @rackup_file if new.nil?

      @rackup_file = new
    end
  end
end
