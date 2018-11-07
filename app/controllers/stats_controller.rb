class StatsController < ApplicationController

  require 'rufus-scheduler'

  @@scheduler = Rufus::Scheduler.new

  @@customers = {}
  @@streams = {}

  def watch
    c = params[:customer_id]
    s = params[:stream_id]

    if c && s

      if @@customers[c].nil? || @@customers[c][s].nil?
        set_watching @@customers, c, s
        set_watching @@streams, s, c

        check_online @@customers, @@streams, c, s
      end

      set_watching @@customers, c, s
      set_watching @@streams, s, c

      render empty: true, status: :ok
    else
      render empty: true, status: :no_content
    end
  end

  def customer
    id = params[:id]
    count @@customers, id
  end

  def stream
    id = params[:id]
    count @@streams, id
  end

  private

  def set_watching(hash, id1, id2)
    if hash[id1].nil?
      hash[id1] = {}
    end
    hash[id1][id2] = Time.now
  end

  def check_online(customers, streams, customer_id, stream_id)
    # Time vars
    online_timeout = 5
    check_time = '3s'
    time_diff = Time.now - customers[customer_id][stream_id]

    check_online = @@scheduler.schedule_every check_time do
      if time_diff > online_timeout
        # delete stream from customer and customer from stream
        customers[customer_id].delete(stream_id)
        streams[stream_id].delete(customer_id)

        # delete customer or stream if empty
        customers.delete(customer_id) if customers[customer_id].length == 0
        streams.delete(stream_id) if streams[stream_id].length == 0

        # stop checking online
        check_online.unschedule()
        check_online.kill()
      end
    end
  end

  def count(hash, id)
    unless hash[id].nil?
      render json: {count: hash[id].length}, status: :ok
    else
      render empty: true, status: :no_content
    end
  end

end
