require 'rufus-scheduler'
require 'httparty'

require_relative '../streams_stats.rb'

def app
  Sinatra::Application
end

scheduler = Rufus::Scheduler.new # max_work_threads: 77

# Test params
c = {
  uri: "http://#{app.settings.bind}:#{app.settings.port}",
  customers: 1000,
  streams: 10,
  test_time: '5m',
  stats_time: '30s'
}

watch_uri =     "#{c[:uri]}/watch"
customer_uri =  "#{c[:uri]}/customer"
stream_uri =    "#{c[:uri]}/stream"

customers = []
streams = []

customers_tasks = []
stats_task = nil


# generate id`s
c[:customers].times do |i|
  customers << rand(1..999999)
end

c[:streams].times do |i|
  streams << rand(1..999999)
end

# start watching tasks
c[:customers].times do |i|

  puts "start watching #{i}"
  customer_id = rand(0..c[:customers])
  stream_id = rand(0..c[:streams])

  # sleep rand(0..5)

  task = scheduler.schedule_every '5s' do
    HTTParty.post(watch_uri, body: {customer_id: customers[customer_id], stream_id: streams[stream_id] })
  end

  customers_tasks << task  

end

# start stats task
stats_task = scheduler.schedule_every c[:stats_time] do
  
  puts 'Customers:'
  puts '==============================='
  customers.each do |c|
    response = HTTParty.get("#{customer_uri}/#{c}")
    result = JSON.parse(response.body)
    puts "customer ##{c} watching streams: #{result['count']}"
  end
  puts '==============================='

  puts 'Streams:'
  puts '==============================='
  streams.each do |s|
    response = HTTParty.get("#{stream_uri}/#{s}")
    result = JSON.parse(response.body)
    puts "stream ##{s} watching clients: #{result['count']}"
  end
  puts '==============================='
  
end

# set end of test
enough = scheduler.in c[:test_time] do
  customers_tasks.each do |t|
    t.unschedule()
  end
  stats_task.unschedule()
  puts 'completed'
end

scheduler.join
