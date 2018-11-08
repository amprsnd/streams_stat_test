require 'sinatra'
require 'sinatra/reloader' if development?

require 'json'
require 'rufus-scheduler'
require 'redis'

require './_methods.rb'
require './_helpers.rb'

# Hello, windooouuuuzzz...
ENV['TZ'] = 'Asia/Almaty'

set :scheduler, Rufus::Scheduler.new
set :redis, {
  enabled: true,
  host: '127.0.0.1',
  port: 6379,
  db: 3,
  password: '',
  adapter: nil
}
redis_connect

set :customers, {}
set :streams, {}

post '/watch' do
  c = params[:customer_id]
  s = params[:stream_id]

  if c && s

    if settings.customers[c].nil? || settings.customers[c][s].nil?
      set_watching settings.customers, c, s, 'customers'
      set_watching settings.streams, s, c, 'streams'

      check_online settings.customers, settings.streams, c, s
    end

    set_watching settings.customers, c, s, 'customers'
    set_watching settings.streams, s, c, 'streams'

    status 200
  else
    status 404
  end
end

get '/customer/:id' do
  count 'customers', settings.customers, params[:id]
end

get '/stream/:id' do
  count 'streams', settings.streams, params[:id]
end
