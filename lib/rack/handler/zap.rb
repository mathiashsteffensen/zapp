# frozen_string_literal: true

require("rack/handler")

module Rack
  module Handler
    # Rack handler for the Zapp web server
    class Zapp
      def self.run(app)
        Zapp::Server.new(app: app).run
      end

      register(:zapp, Rack::Handler::Zapp)
    end
  end
end
