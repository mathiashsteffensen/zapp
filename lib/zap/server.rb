# frozen_string_literal: true

module Zap
  # The Zap HTTP Server, listens on a TCP connection and processes incoming requests
  class Server
    attr_reader :tcp_connection, :worker_pool

    def initialize(port:, host:)
      @tcp_connection = TCPServer.new(host, port)
      @worker_pool = Zap::WorkerPool.new(parallelism: 3)
    end

    def socket
      tcp_connection.accept
    end

    def run
      loop do
        request = Zap::Request.new(socket: tcp_connection.accept, parser: parser)

        worker_pool.process(request: request)
      end
    rescue SignalException, Interrupt, IRB::Abort => e
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
