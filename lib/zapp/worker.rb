# frozen_string_literal: true

require_relative("worker/request_processor")

module Zapp
  # One worker processing requests in parallel
  class Worker < Ractor
    class << self
      def new(context_pipe:, socket_pipe:, index:)
        super(
          context_pipe,
          socket_pipe,
          Zapp.config.dup,
          name: name(index)
        ) do |context_pipe, socket_pipe, config|
          Zapp.__set_config(config)

          Zapp.config.app.prepare if Zapp.config.app.respond_to?(:prepare)

          processor = Zapp::Worker::RequestProcessor.new(
            socket_pipe: socket_pipe,
            context_pipe: context_pipe
          )

          processor.loop
        end
      end

      # Index based name of the worker
      def name(index)
        "zapp-http-#{index + 1}"
      end
    end

    def terminate
      take
    end
  end
end
