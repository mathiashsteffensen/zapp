# frozen_string_literal: true

class MockApp
  attr_reader(:calls)

  def call(env)
    @calls ||= []

    @calls << env

    [200, {}, ["This is a body"]]
  end

  def called?
    calls.size.positive?
  end
end
