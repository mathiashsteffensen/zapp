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
        @workers << Worker.new(
          pipe_: pipe,
          app_: app,
          index: i
        )
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
      workers.map(&:terminate)
    rescue Ractor::RemoteError
      # Ignored
    end
  end
end
