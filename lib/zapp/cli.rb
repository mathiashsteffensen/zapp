# frozen_string_literal: true

require("optionparser")

module Zapp
  # Provides the CLI utility for easily running Ruby 3.0.0+ applications with Zap
  class CLI
    def run
      parse_options

      Zapp::Server.new.run
    end

    private

    def parse_options
      begin
        parse_config_file(location: "./config/zapp.rb")
      rescue StandardError
        # Ignored
      end

      OptionParser.new do |opts|
        opts.banner = "Usage: bundle exec zapp [options]"

        opts.on("-c", "--config-file=FILE", "Config file to use") do |file|
          parse_config_file(location: file)
        end

        opts.on("-h", "--help", "Prints this help") do
          puts(opts)
          exit
        end
      end.parse!
    end

    def parse_config_file(location:)
      config = File.read(
        File.absolute_path(location)
      )

      Zapp.config.instance_eval(config)
    end
  end
end
