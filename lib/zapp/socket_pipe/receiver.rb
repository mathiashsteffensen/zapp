# frozen_string_literal: true

module Zapp
  module SocketPipe
    class Receiver
      attr_reader(:pipe, :raw_tcp_pipe)

      def initialize(pipe:)
        @pipe = pipe
        @raw_tcp_pipe = Ractor.new(Zapp.config, name: "raw-tcp-pipe") do |config|
          server = TCPServer.new(config.host, config.port)

          loop do
            Ractor.yield(server.accept)
          end
        end
      end

      def take
        Ractor.select(pipe, raw_tcp_pipe)[1]
      end
    end
  end
end
