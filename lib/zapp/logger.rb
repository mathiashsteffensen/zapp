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
        @level ||= if ENV["ZAPP_LOG_LEVEL"] != "" && !ENV["ZAPP_LOG_LEVEL"].nil?
                     if LEVELS[ENV["ZAPP_LOG_LEVEL"]].nil?
                       raise(
                         Zapp::ZappError,
                         "Invalid log level '#{ENV['ZAP_LOG_LEVEL']}', must be one of [#{LEVELS.keys.join(', ')}]"
                       )
                     else
                       LEVELS[ENV["ZAP_LOG_LEVEL"]]
                     end
                   else
                     LEVELS[:DEBUG]
                   end
      end

      private

      def log(current_level, msg)
        puts("--- #{@prefix} [#{current_level}] #{msg}") if level <= LEVELS[current_level.to_sym]
      end
    end
    include(Zapp::Logger::Base)

    def initialize
      @prefix = "Zap"
      yield(self) if block_given?
    end

    class << self
      include(Zapp::Logger::Base)
      @prefix = "Zap"
    end
  end
end
