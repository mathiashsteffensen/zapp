# frozen_string_literal: true

class MockSocket
  attr_reader(:was_read, :was_closed, :response)

  def initialize(request_content: "")
    @request_content = request_content
  end

  def recv(_len)
    @was_read = true
    @request_content
  end

  def readpartial(...) = recv(...)

  def write(response_content)
    @response = response_content
  end

  def close
    @was_closed = true
  end

  def eof?
    false
  end
end
