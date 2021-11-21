# frozen_string_literal: true

module Zapp
  # Parses HTTP Requests
  class Parser
    def initialize
      @parser = Puma::HttpParser.new
    end

    def execute!(data, raw)
      @parser.execute(data, raw, 0)
    end
  end
end
