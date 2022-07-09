# frozen_string_literal: true

module Zapp
  # The default logger for zap
  class Logger
    # Base contains all the logging functionality and is included both as class and instance methods of Zap::Logger
    # This allows logging without creating new instances,
    # while allowing Ractors to create their own instances for thread safety
    module Base
      attr_writer(:level, :prefix)

      LEVELS = { DEBUG: 0, INFO: 1, WARN: 2, ERROR: 3 }.freeze

      FROZEN_ENV = ENV.map { |k, v| [k.freeze, v.freeze] }
                      .to_h.freeze

      def debug(msg)
        log("DEBUG", msg)
      end

      def info(msg)
        log("INFO", msg)
      end

      def warn(msg)
        log("WARN", msg)
      end

      def error(msg)
        log("ERROR", msg)
      end

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
        puts("--- #{@prefix} [#{current_level}] #{msg}") if level <= LEVELS[current_level.to_sym]
      end
    end
    include(Zapp::Logger::Base)

    def initialize
      yield(self) if block_given?
    end

    class << self
      include(Zapp::Logger::Base)
    end
  end
end
