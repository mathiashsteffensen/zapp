# frozen_string_literal: true

module Zapp
  class Logger
    # Base contains all the logging functionality and is included both as class and instance methods of Zap::Logger
    # This allows logging without creating new instances,
    # while allowing Ractors to create their own instances for thread safety
    module Base
      attr_writer(:level, :prefix)

      LEVELS = { TRACE: 0, DEBUG: 1, INFO: 2, WARN: 3, ERROR: 4 }.freeze

      FROZEN_ENV = ENV.map { |k, v| [k.freeze, v.freeze] }
                      .to_h.freeze

      # The hash key in Ractor.current that stores the mutex for writing to output
      OUT_IO_MUTEX_KEY = "ZAPP_LOGGER_OUT_IO_MUTEX"

      def trace(msg) = log("TRACE", msg)

      def debug(msg) = log("DEBUG", msg)

      def info(msg) = log("INFO", msg)

      def warn(msg) = log("WARN", msg)

      def error(msg) = log("ERROR", msg)

      def level
        @level ||= begin
          log_level = FROZEN_ENV["LOG_LEVEL"]

          if log_level == "" || log_level.nil?
            LEVELS[:DEBUG]
          else
            resolved_level = LEVELS[log_level.upcase.to_sym]

            if resolved_level.nil?
              raise(
                Zapp::ZappError,
                "Invalid log level '#{log_level.upcase}', must be one of [#{LEVELS.keys.join(', ')}]"
              )
            end

            resolved_level
          end
        end
      end

      def log(current_level, msg, **_tags)
        return unless level <= LEVELS[current_level.to_sym]

        write("--- #{prefix} [#{current_level}] #{msg}\n")
      end

      def flush
        writing_thread_pool.wait_for_termination(0.1)

        out_io_mutex.synchronize do
          out.flush
        end
      end

      # @param new_out [IO]
      def out=(new_out)
        @out = new_out
      end

      protected

      # @return [IO]
      def out
        @out ||= Zapp.config.logger_out_io
      end

      # @return [String]
      def prefix = @prefix ||= Ractor.current.name

      def write(msg)
        writing_thread_pool.post do
          out_io_mutex.synchronize do
            out.print(msg)
          end
        end
      end

      # We really just use this as a queue
      # TODO: There's probably a smarter way of doing this with less overhead,
      # TODO: or maybe we should just actually write logs multi-threaded
      def writing_thread_pool
        @writing_thread_pool ||= Concurrent::ThreadPoolExecutor.new(
          min_threads: 1,
          max_threads: 1,
          max_queue: 100
        )
      end

      def out_io_mutex
        Ractor.current[OUT_IO_MUTEX_KEY] ||= Thread::Mutex.new
      end
    end
  end
end
