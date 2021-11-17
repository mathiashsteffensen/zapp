# frozen_string_literal: true

module Zap
  # The Zap HTTP Server, listens on a TCP connection and processes incoming requests
  class Server
    attr_reader(:tcp_connection, :worker_pool, :host, :port)

    def initialize(app:, port:, host:)
      @host = host
      @port = port

      @tcp_connection = TCPServer.new(host, port)
      @worker_pool = Zap::WorkerPool.new(app: app, parallelism: 3)
    end

    def socket
      tcp_connection.accept
    end

    def run
      log_start

      loop do
        socket = tcp_connection.accept
        next if socket.eof?

        request = Zap::Request.new(socket: socket, parser: parser)

        worker_pool.process(request: request)
      end
    rescue SignalException, IRB::Abort => e
      shutdown(e)
    end

    def shutdown(err = nil)
      Zap::Logger.info("Received signal #{err}") unless err.nil?
      Zap::Logger.info("Gracefully shutting down workers, allowing request processing to finish")

      worker_pool.drain

      Zap::Logger.info("Done. See you next time!")
    end

    private

    def log_start
      Zap::Logger.info("Zap v#{Zap::VERSION} web server running in development")
      Zap::Logger.info("Ready to accept requests")
      Zap::Logger.info("TCP server listening on #{host}:#{port}")
      Zap::Logger.info("Parallel workers: 3")
    end

    def parser
      @parser ||= Puma::HttpParser.new
    end
  end
end
