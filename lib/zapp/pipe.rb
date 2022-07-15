# frozen_string_literal: true

module Zapp
  # Light wrapper around a Ractor for piping messages CSP style
  class Pipe < Ractor
    def self.for(*klasses, null: true)
      Ractor.new(klasses, null) do |klasses, null|
        loop do
          Ractor.yield(
            Ractor.receive_if do |msg|
              return true if null && msg.nil?

              klasses.any? { |klass| msg.is_a?(klass) }
            end
          )
        end
      end
    end

    def self.new
      super do
        loop do
          Ractor.yield(Ractor.receive)
        end
      end
    end
  end
end
