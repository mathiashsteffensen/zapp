# frozen_string_literal: true

module Zapp
  # Light wrapper around a Ractor for piping messages CSP style
  module Pipe
    def self.new
      Ractor.new do
        loop do
          Ractor.yield(Ractor.receive)
        end
      end
    end
  end
end
