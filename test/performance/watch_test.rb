require 'test_helper'
require 'rails/performance_test_help'

class WatchTest < ActionDispatch::PerformanceTest
  test 'watching streams' do
    post '/stats/watch', params: {client_id: 0, stream_id: 0}
  end
end
