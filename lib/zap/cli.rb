# frozen_string_literal: true

module Zap
  # Provides the CLI utility for easily running Ruby 3.0.0+ applications with Zap
  class CLI
    def run
      parse_options
    end

    private

    def parse_options
      Zap.configure do |config|
        OptionParser.new do |opts|
          opts.banner = "Usage: bundle exec zap [options]"

          opts.on("-p", "--parallelism=INT", "Number of native CPU threads to use") do |parallelism|
            config.parallelism = parallelism
          end

          opts.on("-c", "--config-file=FILE", "Config file to use") do |file|
            require_relative(file)
          end

          opts.on("-h", "--help", "Prints this help") do
            puts(opts)
            exit
          end
        end.parse!
      end
    end
  end
end
