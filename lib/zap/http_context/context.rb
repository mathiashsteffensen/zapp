# frozen_string_literal: true

require("zap/http_context/request")
require("zap/http_context/response")

module Zap
  module HTTPContext
    # Context containing request and response
    class Context
      attr_reader(:req, :res)

      def initialize(socket:)
        @socket = socket
        @req = Zap::HTTPContext::Request.new(socket: socket)
        @res = Zap::HTTPContext::Response.new(socket: socket)
      end

      def close
        @socket.close
      end

      def dup
        clone_context = super
        clone_context.instance_variable_set(:@req, @req.dup)
        clone_context.instance_variable_set(:@res, @res.dup)
        clone_context.instance_variable_set(:@socket, @socket.dup)

        clone_context
      end
    end
  end
end
