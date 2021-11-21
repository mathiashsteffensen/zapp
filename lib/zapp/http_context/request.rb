# frozen_string_literal: true

module Zapp
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
        @body = Zapp::InputStream.new(string: parser.body)
        parser.reset
      end

      def parsed?
        body.is_a?(Zapp::InputStream) && !data.nil? && data != {}
      end
    end
  end
end
