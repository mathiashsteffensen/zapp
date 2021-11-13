module Zap
  class Logger
    class << self
      LEVELS = {
        DEBUG: 0,
        INFO: 1,
        WARN: 2,
        ERROR: 3
      }

      @@level = if ENV["ZAP_LOG_LEVEL"] != "" && !ENV["ZAP_LOG_LEVEL"].nil?
                  if LEVELS[ENV["ZAP_LOG_LEVEL"]].nil?
                    raise(Zap::ZapError, "Invalid log level '#{ENV["ZAP_LOG_LEVEL"]}', must be one of [#{LEVELS.keys.join(", ")}]")
                  else
                    LEVELS[ENV["ZAP_LOG_LEVEL"]]
                  end
                else
                  LEVELS[:DEBUG]
                end

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

      private

      def log(level, msg)
        puts("--- Zap [#{level}] #{msg}") if @@level <= LEVELS[level.to_sym]
      end
    end
  end
end