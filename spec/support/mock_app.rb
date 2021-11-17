# frozen_string_literal: true

class MockApp
  attr_reader(:calls)

  def call(env)
    @calls ||= []

    @calls << env

    [200, {}, ["This is a body"]]
  end
end
