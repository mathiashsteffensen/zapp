# frozen_string_literal: true

module Zap
  # The Zap HTTP Server, listens on a TCP connection and processes incoming requests
  class Server
    attr_reader(:tcp_connection, :worker_pool)

    def initialize
      @tcp_connection = TCPServer.new(Zap.config.host, Zap.config.port)
      @worker_pool = Zap::WorkerPool.new(app: Zap.config.app)
    end

    def run
      parser = Puma::HttpParser.new

      log_start

      loop do
        socket = tcp_connection.accept
        next if socket.eof?

        context = Zap::HTTPContext::Context.new(socket: socket)

        context.req.parse!(parser: parser)

        worker_pool.process(context: context)

      rescue Puma::HttpParserError => e
        context.res.write(data: "Invalid HTTP request", status: 500, headers: {})
        Zap::Logger.warn("Puma parser error: #{e}")
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
      Zap::Logger.info("Zap version: #{Zap::VERSION}")
      Zap::Logger.info("Environment: #{Zap.config.mode}")
      Zap::Logger.info("Serving: #{Zap.config.env[Rack::RACK_URL_SCHEME]}://#{Zap.config.host}:#{Zap.config.port}")
      Zap::Logger.info("Parallel workers: #{Zap.config.parallelism}")
      Zap::Logger.info("Ready to accept requests")
    end
  end
end
