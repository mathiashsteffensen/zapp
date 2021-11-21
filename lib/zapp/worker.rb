# frozen_string_literal: true

module Zapp
  # One worker processing requests in parallel
  class Worker < Ractor
    class << self
      def new(pipe_:, app_:, index:)
        # Logger with the name as prefix
        logger_ = Zapp.config.logger_class.new do |logger|
          logger.prefix = name(index)
        end

        super(pipe_, app_, logger_, Zapp.config.dup, name: name(index)) do |pipe, app, logger, config|
          logger.level = 0
          while (context, shutdown = pipe.take)
            break if shutdown

            if config.log_requests
              Zapp::Worker.log_request_time(logger: logger) do
                Zapp::Worker.process(context: context, app: app, logger: logger, config: config)
              end
            else
              Zapp::Worker.process(context: context, app: app, logger: logger, config: config)
            end
          end
        end
      end

      # Processes an HTTP request
      def process(context:, app:, logger:, config:)
        prepare_env(data: context.req.data, body: context.req.body, env: config.env)

        status, headers, response_body_stream = app.call(config.env)

        response_body = body_stream_to_string(response_body_stream)

        context.res.write(data: response_body, status: status, headers: headers)
      rescue StandardError => e
        context.res.write(data: "An unexpected error occurred", status: 500, headers: {})
        logger.error("#{e}\n\n#{e.backtrace&.join(",\n")}") if config.log_uncaught_errors
      ensure
        context.close
      end

      def log_request_time(logger:)
        start = Time.now.to_f * 1000

        yield
      ensure
        logger.info("Processed request in #{((Time.now.to_f * 1000) - start).truncate(2)}ms")
      end

      # Loops over a body stream and returns a single string
      def body_stream_to_string(stream)
        response_body = ""
        stream.each do |s|
          response_body += s
        end

        stream.close if stream.respond_to?(:close)

        response_body
      end

      # Merges HTTP data and body into the env to be passed to the rack app
      def prepare_env(data:, body:, env:)
        data["QUERY_STRING"] = ""
        data["SERVER_NAME"] = data["HTTP_HOST"] || ""
        data["PATH_INFO"] = data["REQUEST_PATH"]
        data["SCRIPT_NAME"] = ""

        env.update(data)

        env.update(Rack::RACK_INPUT => body)
      end

      # Index based name of the worker
      def name(index)
        "zap-http-#{index + 1}"
      end
    end

    def terminate
      Zapp::Logger.debug("Terminating worker #{name}")
      take
    end
  end
end
