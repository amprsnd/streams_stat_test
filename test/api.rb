ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require_relative '../streams_stats.rb'

class MyTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # =========================
  # test watching
  def test_watching
    customer = rand(0..9999)
    stream = rand(0..9999)

    post '/watch', {customer_id: customer, stream_id: stream}

    get "/customer/#{customer}"
    customer_result = JSON.parse last_response.body
    assert_equal 1, customer_result['count']

    get "/stream/#{stream}"
    stream_result = JSON.parse last_response.body

    # trace
    trace_test 'test watching online', customer_result, stream_result
    assert_equal 1, stream_result['count']

    sleep 10

    get "/customer/#{customer}"
    customer_result = JSON.parse last_response.body
    assert_equal 0, customer_result['count']

    get "/stream/#{stream}"
    stream_result = JSON.parse last_response.body

    # trace
    trace_test 'test watching offline', customer_result, stream_result
    assert_equal 0, stream_result['count']
  end

  # =========================
  # data cleaning test
  def test_data_cleaning
    customer = rand(0..10)
    stream = rand(0..10)

    10.times do
      post '/watch', {customer_id: customer, stream_id: stream}
      assert_equal 200, last_response.status
    end

    sleep 10

    trace_test 'data cleaning test', app.settings.customers, app.settings.streams

    assert_equal 0, app.settings.customers.length
    assert_equal 0, app.settings.streams.length

  end

  # =========================
  # test customer
  def test_nonexistent_customer
    customer = rand(0..9999)
    
    get "/customer/#{customer}"
    result = JSON.parse last_response.body

    # trace
    trace_test 'test nonexistent customer', customer, result

    assert last_response.ok?
    assert_equal 0, result['count']
  end

  # test customer streams
  def test_customer_streams
    customer = rand(0..9999)
    streams_quantity = rand(1..10)
    
    streams_quantity.times do
      stream = rand(0..9999)
      post '/watch', {customer_id: customer, stream_id: stream}
      assert_equal 200, last_response.status
    end

    get "/customer/#{customer}"
    result = JSON.parse last_response.body

    # trace
    trace_test 'test customer streams', customer, streams_quantity, result

    assert last_response.ok?
    assert_equal streams_quantity, result['count']
  end

  # =========================
  # test stream
  def test_nonexistent_stream
    stream = rand(0..9999)
    
    get "/stream/#{stream}"
    result = JSON.parse last_response.body

    # trace
    trace_test 'test nonexistent stream', stream, result

    assert last_response.ok?
    assert_equal 0, result['count']
  end

    # test stream customers
    def test_stream_customers
       stream = rand(0..9999)
       customers_quantity = rand(1..10)
      
       customers_quantity.times do
        customer = rand(0..9999)
        post '/watch', {customer_id: customer, stream_id: stream}
        assert_equal 200, last_response.status
      end
  
      get "/stream/#{stream}"
      result = JSON.parse last_response.body
  
      # trace
      trace_test 'test stream customers', stream, customers_quantity, result
  
      assert last_response.ok?
      assert_equal customers_quantity, result['count']
    end


  # helpers
  def trace_test(*args)
    puts ''
    puts '>>>>>>>>>>>>>>>'
    args.each do |d|
      puts d
    end
    puts '<<<<<<<<<<<<<<<'
  end

  end