# frozen_string_literal: true

module Zapp
  # Light wrapper around a Ractor for piping messages CSP style
  module Pipe
    def self.new(receive_if:)
      Ractor.new do
        loop do
          Ractor.yield(Ractor.receive_if(&receive_if))
        end
      end
    end
  end
end
