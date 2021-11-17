# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zap::HTTPContext::Response) do
  subject(:response) { described_class.new(socket: socket) }

  let(:socket) { MockSocket.new }

  describe("#write") do
    subject(:write) { response.write(data: data, status: status) }

    let(:data) { "This is content" }
    let(:status) { 200 }

    before do
      write
    end

    it("formats an HTTP response") do
      expect(socket.response).to(
        eq(
          %(HTTP/1.1 #{status}
Content-Length: #{data.size}

This is content
          )
        )
      )
    end
  end
end
