# frozen_string_literal: true

require_relative("worker/request_processor")

module Zapp
  # One worker processing requests in parallel
  class Worker < Ractor
    class << self
      def new(context_pipe:, socket_pipe:, app:, index:)
        super(
          context_pipe,
          socket_pipe,
          app,
          Zapp.config.dup,
          index,
          name: name(index)
        ) do |context_pipe, socket_pipe, app, config|
          processor = Zapp::Worker::RequestProcessor.new(
            socket_pipe: socket_pipe,
            context_pipe: context_pipe,
            app: app,
            config: config
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
      Zapp::Logger.debug("Terminating worker #{name}")
      take
    end
  end
end
