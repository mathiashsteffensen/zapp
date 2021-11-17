# frozen_string_literal: true

module Zap
  module HTTPContext
    # Represents an HTTP response being sent back to a client
    class Response
      def initialize(socket:)
        @socket = socket
      end

      # TODO: Add headers argument
      def write(data:, status:)
        # rubocop:disable Layout/:RedundantLineBreak
        @socket.write(
          %(HTTP/1.1 #{status}
Content-Length: #{data.size}

#{data}
          )
        )
        # rubocop:enable Layout/:RedundantLineBreak
      end
    end
  end
end
