# frozen_string_literal: true

module Zapp
  class Worker < Ractor
    # Processes HTTP requests
    class RequestProcessor
      attr_reader(:socket_pipe_sender, :context_pipe)

      def initialize(context_pipe:, socket_pipe:)
        @socket_pipe_sender = Zapp::SocketPipe::Sender.new(pipe: socket_pipe)
        @context_pipe = context_pipe
      end

      def loop
        while (context = context_pipe.take)
          if context == Zapp::WorkerPool::SIGNALS[:EXIT]
            Zapp::Logger.trace("Received exit signal, shutting down")
            shutdown
            break
          end

          process = lambda {
            process(context: context)
          }

          if Zapp.config.log_requests
            log_request_time(context: context, &process)
          else
            process.call
          end

          # We send sockets that the client hasn't closed yet,
          # back to the main ractor for HTTP request parsing again
          socket_pipe_sender.push(context.socket) unless context.client_closed?
        end
      end

      private

      # Processes an HTTP request
      def process(context:)
        env = prepare_env(data: context.req.data, body: context.req.body, env: Zapp.config.env.dup)

        status, headers, response_body_stream = Zapp.config.app.call(env)

        response_body = body_stream_to_string(response_body_stream)

        context.res.write(data: response_body, status: status, headers: headers)
      rescue StandardError => e
        context.res.write(data: "An unexpected error occurred", status: 500, headers: {})
        Zapp::Logger.error("#{e}\n\n#{e.backtrace&.join(",\n")}") if Zapp.config.log_uncaught_errors
      end

      # Merges HTTP data and body into the env to be passed to the rack app
      def prepare_env(data:, body:, env:)
        data["QUERY_STRING"] = ""
        data["SERVER_NAME"] = data["HTTP_HOST"] || ""
        data["PATH_INFO"] = data["REQUEST_PATH"]
        data["SCRIPT_NAME"] = ""

        env.update(data)

        env.update(Rack::RACK_INPUT => body)

        env
      end

      def log_request_time(context:)
        start = Time.now.to_f * 1000

        yield

        request_time = ((Time.now.to_f * 1000) - start).truncate(2)
        method = context.req.data["REQUEST_METHOD"]
        path = context.req.data["PATH_INFO"]
        status = context.res.status

        Zapp::Logger.info(
          "#{method} #{path} - Completed in #{request_time}ms with status #{status}"
        )
      end

      # Loops over a body stream and returns a single string
      def body_stream_to_string(stream)
        response_body = ""
        stream.each do |s|
          response_body += s
        end

        stream.close if stream.respond_to?(:close)

        response_body
      end

      def shutdown
        Zapp::Logger.flush
        thread_pool.shutdown
      end

      def thread_pool
        @thread_pool ||= Concurrent::ThreadPoolExecutor.new(
          min_threads: Zapp.config.threads_per_worker,
          max_threads: Zapp.config.threads_per_worker,
          max_queue: 1000
        )
      end
    end
  end
end
