def redis_connect
  r = settings.redis
  pass = r[:password].length > 0 ? "#{r[:password]}@" : ''
  url = "redis://#{pass}@#{r[:host]}:#{r[:port]}/#{r[:db]}"
  r[:adapter] = Redis.new(url: url) if r[:enabled]
end