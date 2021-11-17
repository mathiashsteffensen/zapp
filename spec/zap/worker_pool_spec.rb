# frozen_string_literal: true

require("spec_helper")

class DummyRequest
  def process; end
end

RSpec.describe(Zap::WorkerPool) do
  subject(:worker_pool) { Zap::WorkerPool.new(app: app, parallelism: 1) }

  let(:app) { MockApp.new }

  describe("#process") do
    subject(:process) do
      worker_pool.process(request: request)
      worker_pool.drain
    end

    let(:socket) do
      MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n")
    end
    let(:request) { Zap::Request.new(parser: Puma::HttpParser.new, socket: socket) }

    it("doesn't raise an error") do
      expect { process }
        .not_to(raise_error)
    end
  end
end
