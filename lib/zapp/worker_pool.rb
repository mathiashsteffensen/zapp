# frozen_string_literal: true

module Zapp
  # Manages and dispatches work to a pool of Zap::Worker's
  class WorkerPool
    attr_reader(:context_pipe, :workers, :parallelism)

    SIGNALS = {
      EXIT: :exit
    }.freeze

    def initialize(context_pipe:, socket_pipe:)
      @context_pipe = context_pipe
      @workers = []
      Zapp.config.parallelism.times do |i|
        @workers << Worker.new(
          context_pipe: context_pipe,
          socket_pipe: socket_pipe,
          index: i
        )
      end
    end

    # Sends a socket to one of our workers
    def process(context:)
      context_pipe.send(context)
    end

    # Finishes processing of all requests and shuts down workers
    def drain
      Zapp.config.parallelism.times { process(context: SIGNALS[:EXIT]) }
      workers.map do |w|
        w.terminate
      rescue Ractor::ClosedError
        # Ractor has already exited
      end
    end
  end
end
