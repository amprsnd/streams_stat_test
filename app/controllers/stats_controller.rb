class StatsController < ApplicationController

  @@customers = {}
  @@streams = {}

  # Data Structure Example
  # @@customers = {
  #   customer_id: {
  #     stream_id: 'timestamp', #datetime
  #     stream_id: 'timestamp', #datetime
  #     ...
  #   },
  #   customer_id: {
  #     stream_id: 'timestamp', #datetime
  #     stream_id: 'timestamp', #datetime
  #     ...
  #   },
  #   ...
  # }
  # @@streams = {
  #   stream_id: 'customers_count', #integer
  #   stream_id: 'customers_count', #integer
  #   stream_id: 'customers_count', #integer
  #   ...
  # }

  def watch
  end

  def customer
    render json: @@users.as_json, status: :ok
  end

  def stream
    render json: @@streams.as_json, status: :ok
  end

  private

  def watch_params
    params.permit(:customer_id, :stream_id)
  end

end
