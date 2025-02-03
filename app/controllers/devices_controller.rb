class DevicesController < ApplicationController
  # GET /devices/:id/latest_timestamp
  def latest_timestamp
    timestamp = DeviceReadingService.latest_timestamp(params[:id])
    render json: { latest_timestamp: timestamp }, status: :ok
  end

  # GET /devices/:id/cumulative_count
  def cumulative_count
    count = DeviceReadingService.cumulative_count(params[:id])
    render json: { cumulative_count: count }, status: :ok
  end
end

