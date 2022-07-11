# frozen_string_literal: true

require("webrick")

module Zapp
  module HTTPContext
    # Represents an HTTP Request to be processed by a worker
    class Request
      attr_reader(:raw, :data, :body)

      # Request parsing is done threaded, but not in separate Ractors.
      # So we allocate an HTTP parser per thread and assign it to this hash key in Thread.current
      PARSER_THREAD_HASH_KEY = "PUMA_PARSER_INSTANCE"

      def initialize(socket:)
        # Max Request size of 8KB TODO: Make a config value for this setting
        @raw = socket.readpartial(8192)
        @data = {}

        parser.execute(data, raw, 0)

        @body = Zapp::InputStream.new(string: parser.body)

        parser.reset
      end

      def parser
        Thread.current[PARSER_THREAD_HASH_KEY] ||= Puma::HttpParser.new
      end
    end
  end
end
