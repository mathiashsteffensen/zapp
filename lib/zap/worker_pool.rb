# frozen_string_literal: true

module Zap
  # Manages and dispatches work to a pool of Ractor's
  class WorkerPool
    attr_reader :pipe, :workers, :parallelism

    def initialize(app:, parallelism:)
      @parallelism = parallelism

      @pipe = Ractor.new do
        loop do
          Ractor.yield(Ractor.receive)
        end
      end

      @workers = []
      parallelism.times do |i|
        @workers << Ractor.new(pipe, app, ENV.to_hash, name: "zap-http-#{i + 1}") do |p, app, env|
          while (request, shutdown = p.take)
            break if shutdown

            request.process(app: app, env: env)
          end
        end
      end
    end

    # Sends data through the pipe to one of our workers,
    # sends a tuple of [request, shutdown], if shutdown is true it breaks from its processing loop
    # otherwise the worker processes the request
    def process(request:, shutdown: false)
      pipe.send([request.dup, shutdown], move: true)
    end

    # Finishes processing of all requests and shuts down workers
    def drain
      parallelism.times { process(request: nil, shutdown: true) }
      workers.map(&:take)
    rescue Ractor::RemoteError
      # Ignored
    end
  end
end
