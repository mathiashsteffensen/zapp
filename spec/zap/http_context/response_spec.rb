# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zapp::HTTPContext::Response) do
  subject(:response) { described_class.new(socket: socket) }

  let(:socket) { MockSocket.new }

  describe("#write") do
    subject(:write) { response.write(data: data, status: status, headers: headers) }

    let(:data) { "This is content" }
    let(:status) { 200 }

    before do
      write
    end

    context("when Content-Length header is not specified") do
      let(:headers) { {} }

      it("formats an HTTP response with the header added") do
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

    context("when Content-Length header is specified") do
      # rubocop:disable Style/StringHashKeys
      let(:headers) { { "Content-Length" => 755 } }
      # rubocop:enable Style/StringHashKeys

      it("formats an HTTP response with the header added") do
        expect(socket.response).to(
          eq(
            %(HTTP/1.1 #{status}
Content-Length: 755

This is content
)
          )
        )
      end
    end
  end
end
