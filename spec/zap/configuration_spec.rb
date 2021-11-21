# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zap::Configuration) do
  subject(:config) { Zap.config }

  context("when used like a normal ruby config block") do
    before do
      Zap.configure do |config|
        config.parallelism = 5
        config.log_requests = false
        config.logger_class = self
        config.log_uncaught_errors = false
      end
    end

    it("sets the value on the config object") do
      expect(config.parallelism).to(eq(5))
      expect(config.log_requests).to(eq(false))
      expect(config.logger_class).to(eq(self))
      expect(config.log_uncaught_errors).to(eq(false))
    end
  end

  context("when used as a DSL") do
    before do
      Zap.config.instance_eval do
        parallelism(5)
        log_requests(false)
        logger_class("Class")
        log_uncaught_errors(false)
      end
    end

    it("sets the value on the config object") do
      expect(config.parallelism).to(eq(5))
      expect(config.log_requests).to(eq(false))
      expect(config.logger_class).to(eq("Class"))
      expect(config.log_uncaught_errors).to(eq(false))
    end
  end
end
