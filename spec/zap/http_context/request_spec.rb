# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zapp::HTTPContext::Request) do
  subject(:request) { described_class.new(socket: socket) }

  let(:socket) { MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n") }

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
