# frozen_string_literal: true

# This file is used by Rack-based web servers to start the application.

require_relative("config/environment")

run(RailsApp::Application)
