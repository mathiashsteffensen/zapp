# frozen_string_literal: true

module Zap
  # Manages and dispatches work to a pool of Ractor's
  class WorkerPool
    attr_reader :pipe, :workers, :parallelism

    def initialize(parallelism:)
      @parallelism = parallelism

      @pipe = Ractor.new do
        loop do
          Ractor.yield(Ractor.receive)
        end
      end

      @workers = []
      parallelism.times do |i|
        @workers << Ractor.new(pipe, name: "zap-http-#{i}") do |p|
          while (request, shutdown = p.take)
            break if shutdown
            request.process
          end
        end
      end
    end

    def process(request:, shutdown: false)
      pipe.send([request.dup, shutdown], move: true)
    end

    # Finishes processing of all requests and shuts down workers
    def drain
      parallelism.times { process(request: nil, shutdown: true) }
      workers.map(&:take)
    end
  end
end
