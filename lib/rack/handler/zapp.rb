# frozen_string_literal: true

require("rack/handler")

module Rack
  module Handler
    # Rack handler for the Zapp web server
    class Zapp
      register(:zapp, Rack::Handler::Zapp)

      def self.run(app)
        Zapp.config.app = app
        Zapp::Server.new.run
      end
    end
  end
end
