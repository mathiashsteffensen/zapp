# frozen_string_literal: true

require_relative("logger/base")

module Zapp
  # The default logger for Zapp
  class Logger
    include(Zapp::Logger::Base)

    def initialize
      yield(self) if block_given?
    end

    class << self
      # The hash key in Ractor.current that stores the global Zapp::Logger instance
      GLOBAL_INSTANCE_KEY = "ZAPP_LOGGER_INSTANCE"

      def instance
        Ractor.current[GLOBAL_INSTANCE_KEY] ||= new
      end

      private

      def method_missing(symbol, *args)
        if respond_to_missing?(symbol)
          instance.public_send(symbol, *args)
        else
          super
        end
      end

      def respond_to_missing?(symbol, include_private = false)
        instance.respond_to?(symbol) || super(symbol, include_private)
      end
    end
  end
end
