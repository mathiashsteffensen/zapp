# frozen_string_literal: true

require("spec_helper")

class DummyRequest
  def process; end
end

RSpec.describe(Zapp::WorkerPool) do
  subject(:worker_pool) { Zapp::WorkerPool.new(app: app) }

  let(:app) { MockApp.new }

  describe("#process") do
    subject(:process) do
      worker_pool.process(context: context)
      worker_pool.drain
    end

    let(:context) { Zapp::HTTPContext::Context.new(socket: socket) }
    let(:socket) do
      MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n")
    end

    it("doesn't raise an error") do
      expect { process }
        .not_to(raise_error)
    end
  end
end
