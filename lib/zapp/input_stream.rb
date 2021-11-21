# frozen_string_literal: true

module Zapp
  # Represents an input stream with the HTTP data passed to rack.input
  # Read the Input Stream part of the Rack Specification here https://github.com/rack/rack/blob/master/SPEC.rdoc#label-The+Input+Stream
  class InputStream
    def initialize(string:)
      @string = string
      @next_index_to_read = 0
    end

    def read(length = nil, buffer = nil)
      returning = if length.nil?
                    raw_read
                  else
                    string = raw_read(end_index: @next_index_to_read + length)
                    string == "" ? nil : string
                  end

      if buffer.nil?
        returning
      else
        buffer << returning
      end
    end

    def each(&block)
      [read].each(&block)
    end

    def gets
      return unless @next_index_to_read < @string.length

      read
    end

    def rewind
      @next_index_to_read = 0
    end

    private

    def raw_read(end_index: @string.length)
      returning = @string.slice(@next_index_to_read...end_index)

      @next_index_to_read = end_index

      returning
    end
  end
end
