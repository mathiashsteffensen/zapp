# frozen_string_literal: true

require("spec_helper")

RSpec.describe(Zap::Request) do
  subject(:request) { described_class.new(parser: Puma::HttpParser.new, socket: socket) }

  let(:socket) { MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n") }

  describe "#process" do
    subject(:process) { request.process(app: app, env: env) }

    # Ensure we conform to the Rack specification
    let(:mock_app) { MockApp.new }
    let(:app) { Rack::Lint.new(mock_app) }
    let(:env) { {} }

    before do
      process
    end

    context "when it's a valid HTTP request" do
      let(:socket) { MockSocket.new(request_content: "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n") }

      it "reads from the socket" do
        expect(socket.was_read).to(eq(true))
      end

      it "calls the app" do
        expect(mock_app.calls.length).to(eq(1))
        expect(mock_app.calls.first).to(
          match(
            # rubocop:disable Style/StringHashKeys
            hash_including(
              "HTTP_VERSION" => "HTTP/1.1",
              "PATH_INFO" => "/admin/users",
              "QUERY_STRING" => "search=%27%%27",
              "REQUEST_METHOD" => "GET",
              "REQUEST_PATH" => "/admin/users",
              "REQUEST_URI" => "/admin/users?search=%27%%27",
              "SCRIPT_NAME" => "",
              "SERVER_NAME" => ""
            )
            # rubocop:enable Style/StringHashKeys
          )
        )
      end

      it "closes the socket when it's done" do
        expect(socket.was_closed).to(eq(true))
      end
    end

    context "when it's an invalid HTTP request" do
      let(:socket) { MockSocket.new(request_content: "awdawæø' wdawa") }
      let(:app) { MockApp.new }

      it "reads from the socket" do
        expect(socket.was_read).to(eq(true))
      end

      it "doesn't call the app" do
        expect(app.calls).to(be_nil)
      end

      it "closes the socket when it's done" do
        expect(socket.was_closed).to(eq(true))
      end
    end
  end
end
