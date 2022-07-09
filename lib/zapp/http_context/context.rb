# frozen_string_literal: true

require_relative("request")
require_relative("response")

module Zapp
  module HTTPContext
    # Context containing request and response
    class Context
      attr_reader(:req, :res, :socket)

      def initialize(socket:, logger: Zapp::Logger)
        @socket = socket
        @req = Zapp::HTTPContext::Request.new(socket: socket)
        @res = Zapp::HTTPContext::Response.new(socket: socket)
      rescue Puma::HttpParserError => e
        res.write(data: "Invalid HTTP request", status: 400, headers: {})
        logger.warn("Puma parser error: #{e}")
        logger.debug("HTTP request raw: #{context.req.raw}")
      end

      def close
        @socket.close
      end

      def client_closed?
        req.data["HTTP_CONNECTION"] == "close"
      end
    end
  end
end
