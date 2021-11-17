# frozen_string_literal: true

module Zap
  module HTTPContext
    # Represents an HTTP Request to be processed by a worker
    class Request
      attr_reader(:raw, :data, :body)

      def initialize(socket:)
        raise(EOFError) if socket.eof?

        # Max Request size of 8KB TODO: Make a config value for this setting
        @raw = socket.readpartial(8192)
        @data = {}
      end

      def parse!(parser: Puma::HttpParser.new)
        parser.execute(data, raw, 0)
        @body = Zap::InputStream.new(string: parser.body)
      end

      def parsed?
        body.is_a?(Zap::InputStream) && !data.nil? && data != {}
      end
    end
  end
end
