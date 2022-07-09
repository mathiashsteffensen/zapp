# frozen_string_literal: true

module Zapp
  module SocketPipe
    class Sender
      attr_reader(:pipe)

      def initialize(pipe:)
        @pipe = pipe
      end

      def push(socket)
        pipe.send(socket)
      end
    end
  end
end
