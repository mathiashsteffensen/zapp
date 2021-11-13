# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zap) do
  it "has a version number" do
    expect(Zap::VERSION).not_to(be(nil))
  end
end
