class ReadingsController < ApplicationController
  # POST /readings
  def create
    device_request = DeviceReadingRequest.new(readings_params)

    if device_request.valid?
      DeviceReadingService.store_readings(device_request)
      render json: { message: 'Readings processed successfully' }, status: :ok
    else
      render json: { errors: device_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def readings_params
    params.permit(:id, readings: [:timestamp, :count])
  end
end
