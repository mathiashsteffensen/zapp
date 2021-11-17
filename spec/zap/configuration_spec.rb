# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zap::Configuration) do
  subject(:config) { Zap.config }

  before do
    Zap.configure do |config|
      config.parallelism = 5
      config.log_requests = false
    end
  end

  it("sets the value on the Singleton class") do
    expect(config.parallelism).to(eq(5))
    expect(config.log_requests).to(eq(false))
  end
end
