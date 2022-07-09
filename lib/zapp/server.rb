# frozen_string_literal: true

module Zapp
  # The Zap HTTP Server, listens on a TCP connection and processes incoming requests
  class Server
    attr_reader(:worker_pool, :socket_pipe_receiver)

    def initialize
      @socket_pipe = Ractor.new do
        loop do
          Ractor.yield(Ractor.receive_if { |msg| msg.is_a?(TCPSocket) })
        end
      end
      @context_pipe = Ractor.new do
        loop do
          Ractor.yield(Ractor.receive_if { |msg| msg.is_a?(Zapp::HTTPContext::Context) })
        end
      end

      @socket_pipe_receiver = Zapp::SocketPipe::Receiver.new(pipe: @socket_pipe)

      @worker_pool = Zapp::WorkerPool.new(app: Zapp.config.app, socket_pipe: @socket_pipe, context_pipe: @context_pipe)
    end

    def run
      log_start

      loop do
        socket = socket_pipe_receiver.take

        next if socket.eof?

        parsing_thread_pool.post do
          ctx = Zapp::HTTPContext::Context.new(socket: socket)

          worker_pool.process(context: ctx) unless ctx.client_closed? # Parsing failed
        end
      rescue Errno::ECONNRESET
        next
      end
    rescue SignalException, IRB::Abort => e
      shutdown(e)
    end

    def shutdown(err = nil)
      Zapp::Logger.info("Received signal #{err}") unless err.nil?
      Zapp::Logger.info("Gracefully shutting down workers, allowing request processing to finish")

      socket_pipe_receiver.drain
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

    def parsing_thread_pool
      @parsing_thread_pool ||= Concurrent::ThreadPoolExecutor.new(
        min_threads: Zapp.config.parallelism,
        max_threads: Zapp.config.parallelism,
        max_queue: Zapp.config.parallelism * 1_000
      )
    end
  end
end
