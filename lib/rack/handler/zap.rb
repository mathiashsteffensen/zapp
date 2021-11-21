# frozen_string_literal: true

require("rack/handler")

module Rack
  module Handler
    # Rack handler for the Zap web server
    class Zap
      def self.run(app)
        Zap::Server.new(app: app).run
      end

      register(:zap, Rack::Handler::Zap)
    end
  end
end
