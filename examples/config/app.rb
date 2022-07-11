class App
  def self.call(env)
    [200, {}, ["Hello from Zapp", env.to_s]]
  end
end
