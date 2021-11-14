# frozen_string_literal: true

module Zap
  # Represents an HTTP Request to be processed by a worker
  # Most of the logic happens here, the worker simply calls Request#process
  class Request
    attr_reader :socket, :data, :request_body, :start

    def initialize(socket:, parser:)
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

      # Might still be interesting to know about when debugging
      Zap::Logger.debug("Failed to parse HTTP request #{e}")
    end

    def process(app:, env:)
      return write_response(data: "Invalid request", code: 400) if data == {}

      data["QUERY_STRING"] ||= ""
      data["SERVER_NAME"] = data["HTTP_HOST"] || ""

      env.update(data)

      env["SCRIPT_NAME"] ||= ""
      env["PATH_INFO"] ||= env["REQUEST_PATH"]

      status, _headers, response_body_stream = app.call(env)

      response_body = ""
      response_body_stream.each do |s|
        response_body += s
      end

      write_response(data: response_body, code: status)
    ensure
      socket.close
    end

    # TODO: Add headers argument
    def write_response(data:, code:)
      socket.write(%(HTTP/1.1 #{code} Content-Length: #{data.size} #{data} ))
    end
  end
end
