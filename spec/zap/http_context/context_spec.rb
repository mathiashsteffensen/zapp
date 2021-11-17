# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zap::HTTPContext::Context) do
  subject(:context) { described_class.new(socket: socket) }

  let(:socket) { MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n") }

  describe("#req") do
    subject(:request) { context.req }

    describe("#parsed?") do
      subject { request.parsed? }

      context("when not parsed") do
        it { is_expected.to(eq(false)) }
      end

      context("when parsed") do
        before do
          request.parse!
        end

        it {
          is_expected.to(eq(true))
        }
      end
    end
  end

  describe("#res") do
    subject(:response) { context.res }

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
end
