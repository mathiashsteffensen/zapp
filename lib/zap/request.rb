# frozen_string_literal: true

module Zap
  # Represents an HTTP Request to be processed by a worker
  # Most of the logic happens here, the worker simply calls Request#process
  class Request
    attr_reader :socket, :data, :body

    def initialize(socket:, parser:)
      @socket = socket
      @data = {}

      raw_request = socket.readpartial(8192) # Max Request size of 8KB TODO: Make a config value for this setting

      parser.execute(@data, raw_request, 0)

      @body = parser.body

      parser.reset
    rescue Puma::HttpParserError, EOFError => e
      # Ignore EOFError's and HttpParserError's
      # Any client can essentially send any data packet so no reason to do anything about invalid packets

      # Might still be interesting to know about when debugging
      Zap::Logger.debug("Failed to parse HTTP request #{e}")
    end

    def process
      if data == {}
        write_response(data: "Invalid request", code: 400)
        return socket.close
      end

      puts(data)

      socket.close
    end

    # TODO: Add headers argument
    def write_response(data:, code:)
      socket.write(%Q(HTTP/1.1 #{code}

#{data}))
    end
  end
end
