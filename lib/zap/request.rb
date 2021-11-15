# frozen_string_literal: true

module Zap
  # Represents an HTTP Request to be processed by a worker
  # Most of the logic happens here, the worker simply calls Request#process
  class Request
    attr_reader :socket, :data, :request_body

    def initialize(socket:, parser:)
      @start = Time.now.to_f * 1000
      @socket = socket
      @data = {}

      return if socket.eof?

      # Max Request size of 8KB TODO: Make a config value for this setting
      raw_request = socket.readpartial(8192)

      parser.execute(@data, raw_request, 0)

      @request_body = parser.body

      parser.reset
    rescue Puma::HttpParserError, EOFError => e
      # Ignore EOFError's and HttpParserError's
      # Any client can essentially send any data packet so no reason to do anything about invalid packets
      @data = {}

      # Might still be interesting to know about when debugging
      Zap::Logger.debug("Failed to parse HTTP request #{e}")
    end

    def process(app:, env:, logger:)
      return write_response(data: "Invalid request", code: 400) if data == {}

      prepare_env(data: data, env: env)

      status, _headers, response_body_stream = app.call(env)

      response_body = ""
      response_body_stream.each do |s|
        response_body += s
      end

      write_response(data: response_body, code: status)
    ensure
      socket.close
      logger.info("Processed request in #{((Time.now.to_f * 1000) - @start).truncate(2)}ms")
    end

    private

    def prepare_env(data:, env:)
      data["QUERY_STRING"] ||= ""
      data["SERVER_NAME"] = data["HTTP_HOST"] || ""
      data["PATH_INFO"] ||= data["REQUEST_PATH"]
      data["SCRIPT_NAME"] ||= ""

      env.update(data)

      env.update(
        Rack::RACK_VERSION => [2, 2, 3],
        Rack::RACK_INPUT => Zap::InputStream.new(string: request_body),
        Rack::RACK_ERRORS => $stderr,
        Rack::RACK_MULTITHREAD => false,
        Rack::RACK_MULTIPROCESS => true,
        Rack::RACK_RUNONCE => false,
        Rack::RACK_URL_SCHEME => %w[yes on 1].include?(env["HTTPS"]) ? "https" : "http"
      )
    end

    # TODO: Add headers argument
    def write_response(data:, code:)
      # rubocop:disable Layout/:RedundantLineBreak
      socket.write(
        %(HTTP/1.1 #{code}
Content-Length: #{data.size}

#{data}
        )
      )
      # rubocop:enable Layout/:RedundantLineBreak
    end
  end
end
