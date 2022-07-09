# frozen_string_literal: true

class App
  def self.call(_env)
    [200, {}, ["Hello from Zapp"]]
  end
end

parallelism(4)
app(App)
