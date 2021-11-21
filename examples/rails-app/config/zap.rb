# frozen_string_literal: true

class App
  def self.call(_env)
    [200, {}, ["Hello from Zap"]]
  end
end

parallelism(2)
app(App)
