# frozen_string_literal: true

module Zapp
  # Light wrapper around a Ractor for piping messages CSP style
  class Pipe < Ractor
    def self.new
      super do
        loop do
          Ractor.yield(Ractor.receive)
        end
      end
    end
  end
end
