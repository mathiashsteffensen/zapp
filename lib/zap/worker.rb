# frozen_string_literal: true

module Zap
  # One worker processing requests in parallel
  class Worker < Ractor
    class << self
      def new(pipe_:, app_:, index:)
        # Index based name of the worker
        name = "zap-http-#{index + 1}"

        env_ = ENV.to_hash

        # Logger with the name as prefix
        logger_ = Zap.config.logger_class.new
        logger_.prefix = name

        # A Parser for the worker to use
        parser_ = Puma::HttpParser.new

        super(pipe_, app_, env_, logger_, parser_, name: name) do |pipe, app, env, logger, _parser|
          logger.level = 0
          while (request, shutdown = pipe.take)
            break if shutdown

            request.process(app: app, env: env, logger: logger)
          end
        end
      end
    end

    def terminate
      Zap::Logger.debug("Terminating worker #{name}")
      take
    end
  end
end
