# frozen_string_literal: true

require("spec_helper")

class DummyRequest
  def process; end
end

RSpec.describe(Zap::WorkerPool) do
  subject(:worker_pool) { Zap::WorkerPool.new(parallelism: 1) }

  describe "#process" do
    subject(:process) { worker_pool.process(request: request) }

    let(:request) { DummyRequest.new }

    it "doesn't raise an error" do
      expect { process }
        .not_to(raise_error)
    end
  end
end
