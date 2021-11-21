# frozen_string_literal: true

require("zapp/http_context/request")
require("zapp/http_context/response")

module Zapp
  module HTTPContext
    # Context containing request and response
    class Context
      attr_reader(:req, :res)

      def initialize(socket:)
        @socket = socket
        @req = Zapp::HTTPContext::Request.new(socket: socket)
        @res = Zapp::HTTPContext::Response.new(socket: socket)
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
