# frozen_string_literal: true

require("json")

class App
  def self.call(env)
    [200, {}, ["Hello from Zapp", JSON.generate(env)]]
  end
end

parallelism(4)
threads_per_worker(25)
app(App)
