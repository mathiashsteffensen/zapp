# frozen_string_literal: true

require("zap/http_context/request")
require("zap/http_context/response")

module Zap
  module HTTPContext
    # Context containing request and response
    class Context
      attr_reader(:req, :res)

      def initialize(socket:)
        @req = Zap::HTTPContext::Request.new(socket: socket)
        @res = Zap::HTTPContext::Response.new(socket: socket)
      end
    end
  end
end
