require 'rails_helper'
require 'securerandom'

RSpec.describe 'Readings API', type: :request do
  let(:device_id) { SecureRandom.uuid }

  after(:each) do
    Rails.cache.delete("device:#{device_id}")
  end

  describe 'POST /readings' do
    it 'returns 200 and processes valid readings' do
      # We'll use two different timestamps: current time and current_time + 60s
      timestamp1 = Time.now.utc.iso8601
      timestamp2 = (Time.now + 60).utc.iso8601

      payload = {
        id: device_id,
        readings: [
          { timestamp: timestamp1, count: 2 },
          { timestamp: timestamp2, count: 15 }
        ]
      }

      post '/readings',
           params: payload.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('message' => 'Readings processed successfully')

      device_data = Rails.cache.read("device:#{device_id}")
      expect(device_data[:cumulative_count]).to eq(17)
      expect(device_data[:latest_timestamp]).to eq(timestamp2)
    end

    it 'returns 422 (Unprocessable Entity) for invalid payload' do
      # Missing 'id' and 'readings'
      invalid_payload = {}

      post '/readings',
           params: invalid_payload.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
      error_body = JSON.parse(response.body)
      expect(error_body['errors']).to include("Id can't be blank")
      expect(error_body['errors']).to include('Readings must be an array and cannot be empty')
    end
  end
end
