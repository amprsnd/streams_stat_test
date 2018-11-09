helpers do

  def set_watching(hash, id1, id2, key)
    if hash[id1].nil?
      hash[id1] = {}
    end
    hash[id1][id2] = DateTime.now.strftime('%s').to_i
    
    to_redis(key, hash)
  end

  def check_online(customers, streams, customer_id, stream_id)
    # Time vars
    online_timeout = 5
    check_time = '3s'
    time_diff = 0

    check_online = settings.scheduler.schedule_every check_time do
      time_diff = DateTime.now.strftime('%s').to_i - customers[customer_id][stream_id]

      if time_diff > online_timeout
        # delete stream from customer and customer from stream
        customers[customer_id].delete(stream_id)
        streams[stream_id].delete(customer_id)

        # delete customer or stream if empty
        customers.delete(customer_id) if customers[customer_id].length == 0
        streams.delete(stream_id) if streams[stream_id].length == 0

        to_redis('customers', customers)
        to_redis('streams', streams)

        # stop checking online
        check_online.unschedule()
        check_online.kill()   
      end
    end
  end

  def count(key, hash, id)
    from_redis(key)
    count = hash[id].nil? ? 0 : hash[id].length

    status 200
    content_type :json
    {count: count}.to_json
  end

  def to_redis(key, hash)
    if settings.redis[:enabled]
      redis = settings.redis[:adapter]
      redis.set(key, hash.to_json)
    end
  end

  def from_redis(key)
    if settings.redis[:enabled]
      redis = settings.redis[:adapter]
      hash = JSON.parse(redis.get(key))
    end
  end
end
