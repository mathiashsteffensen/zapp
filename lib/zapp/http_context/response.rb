# frozen_string_literal: true

module Zapp
  module HTTPContext
    # Represents an HTTP response being sent back to a client
    class Response
      def initialize(socket:)
        @socket = socket
      end

      # TODO: Add headers argument
      def write(data:, status:, headers:)
        response = "HTTP/1.1 #{status}\n"

        response += "Content-Length: #{data.size}\n" unless headers["Content-Length"]

        headers.each do |k, v|
          response += "#{k}: #{v}\n"
        end

        response += "\n#{data}\n"

        @socket.write(response)
      end
    end
  end
end
