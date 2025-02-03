require 'rails_helper'
require 'securerandom'

RSpec.describe 'Devices API', type: :request do
  let(:device_id) { SecureRandom.uuid }

  after(:each) do
    Rails.cache.delete("device:#{device_id}")
  end

  describe 'GET /devices/:id/latest_timestamp' do
    it 'returns the latest timestamp when device data exists' do
      test_timestamp = Time.now.utc.iso8601
      device_data = {
        readings: {},
        cumulative_count: 10,
        latest_timestamp: test_timestamp
      }
      Rails.cache.write("device:#{device_id}", device_data)

      get "/devices/#{device_id}/latest_timestamp"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('latest_timestamp' => test_timestamp)
    end

    it 'returns nil if no device data exists' do
      get "/devices/#{device_id}/latest_timestamp"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('latest_timestamp' => nil)
    end
  end

  describe 'GET /devices/:id/cumulative_count' do
    it 'returns the cumulative count when device data exists' do
      device_data = {
        readings: {},
        cumulative_count: 42,
        latest_timestamp: Time.now.utc.iso8601
      }
      Rails.cache.write("device:#{device_id}", device_data)

      get "/devices/#{device_id}/cumulative_count"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('cumulative_count' => 42)
    end

    it 'returns 0 if no device data exists' do
      get "/devices/#{device_id}/cumulative_count"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('cumulative_count' => 0)
    end
  end
end
