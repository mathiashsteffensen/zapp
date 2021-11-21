# frozen_string_literal: true

module Zapp
  # The Zap HTTP Server, listens on a TCP connection and processes incoming requests
  class Server
    attr_reader(:tcp_connection, :worker_pool)

    def initialize
      @tcp_connection = TCPServer.new(Zapp.config.host, Zapp.config.port)
      @worker_pool = Zapp::WorkerPool.new(app: Zapp.config.app)
    end

    def run
      parser = Puma::HttpParser.new

      log_start

      loop do
        socket = tcp_connection.accept
        next if socket.eof?

        context = Zapp::HTTPContext::Context.new(socket: socket)

        context.req.parse!(parser: parser)

        worker_pool.process(context: context)

      rescue Puma::HttpParserError => e
        context.res.write(data: "Invalid HTTP request", status: 500, headers: {})
        Zapp::Logger.warn("Puma parser error: #{e}")
      end
    rescue SignalException, IRB::Abort => e
      shutdown(e)
    end

    def shutdown(err = nil)
      Zapp::Logger.info("Received signal #{err}") unless err.nil?
      Zapp::Logger.info("Gracefully shutting down workers, allowing request processing to finish")

      worker_pool.drain

      Zapp::Logger.info("Done. See you next time!")
    end

    private

    def log_start
      Zapp::Logger.info("Zap version: #{Zapp::VERSION}")
      Zapp::Logger.info("Environment: #{Zapp.config.mode}")
      Zapp::Logger.info("Serving: #{Zapp.config.env[Rack::RACK_URL_SCHEME]}://#{Zapp.config.host}:#{Zapp.config.port}")
      Zapp::Logger.info("Parallel workers: #{Zapp.config.parallelism}")
      Zapp::Logger.info("Ready to accept requests")
    end
  end
end
