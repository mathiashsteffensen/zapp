# frozen_string_literal: true

module Zap
  # The Zap HTTP Server, listens on a TCP connection and processes incoming requests
  class Server
    attr_reader :tcp_connection, :worker_pool

    def initialize(app:, port:, host:)
      Zap::Logger.info("Opening TCP server at #{host}:#{port}")

      @tcp_connection = TCPServer.new(host, port)

      Zap::Logger.info("Creating Zap::WorkerPool with 3 parallel workers")
      @worker_pool = Zap::WorkerPool.new(app: app, parallelism: 3)
    end

    def socket
      tcp_connection.accept
    end

    def run
      Zap::Logger.info("Zap v#{Zap::VERSION} web server running in development")
      Zap::Logger.info("Ready to accept requests")

      loop do
        socket = tcp_connection.accept
        next if socket.eof?

        request = Zap::Request.new(socket: socket, parser: parser)

        worker_pool.process(request: request)
      end
    rescue SignalException, IRB::Abort => e
      Zap::Logger.info("Received signal #{e}")
      Zap::Logger.info("Gracefully shutting down workers, allowing request processing to finish")

      worker_pool.drain

      Zap::Logger.info("Done. See you next time!")
    end

    def parser
      @parser ||= Puma::HttpParser.new
    end
  end
end
