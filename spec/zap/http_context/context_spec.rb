# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zapp::HTTPContext::Context) do
  subject(:context) { described_class.new(socket: socket) }

  let(:socket) { MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n") }

  describe("#res") do
    subject(:response) { context.res }

    describe("#write") do
      subject(:write) { response.write(data: data, status: status, headers: {}) }

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

  describe("#close") do
    subject(:close) { context.close }

    before do
      close
    end

    it("closes the socket") do
      expect(socket.was_closed).to(eq(true))
    end
  end
end
