# spec/services/device_reading_service_spec.rb
require 'rails_helper'
require 'securerandom'

RSpec.describe DeviceReadingService, type: :service do
  let(:device_id) { SecureRandom.uuid }

  after(:each) do
    # Clean up the cache after each test
    Rails.cache.delete("device:#{device_id}")
  end

  describe '.store_readings' do
    it 'stores unique readings and updates cumulative_count & latest_timestamp' do
      timestamp1 = Time.now.utc.iso8601
      timestamp2 = (Time.now + 60).utc.iso8601

      reading1_count = 2
      reading2_count = 15

      device_request = DeviceReadingRequest.new(
        id: device_id,
        readings: [
          { timestamp: timestamp1, count: reading1_count},
          { timestamp: timestamp2, count: reading2_count }
        ]
      )

      DeviceReadingService.store_readings(device_request)
      stored_data = Rails.cache.read("device:#{device_id}")

      expect(stored_data[:readings].keys.size).to eq(2)
      expect(stored_data[:cumulative_count]).to eq(reading1_count + reading2_count)
      expect(stored_data[:latest_timestamp]).to eq(timestamp2)
    end

    it 'ignores duplicate timestamps' do
      timestamp = Time.now.utc.iso8601

      request1 = DeviceReadingRequest.new(
        id: device_id,
        readings: [{ timestamp: timestamp, count: 15 }]
      )
      DeviceReadingService.store_readings(request1)

      request2 = DeviceReadingRequest.new(
        id: device_id,
        readings: [{ timestamp: timestamp, count: 100 }]
      )
      DeviceReadingService.store_readings(request2)

      stored_data = Rails.cache.read("device:#{device_id}")

      expect(stored_data[:readings].keys.size).to eq(1)
      expect(stored_data[:cumulative_count]).to eq(15)
    end

    it 'does not write to the cache if no new readings are added' do
      timestamp = Time.now.utc.iso8601
      existing_data = {
        readings: { timestamp => 10 },
        cumulative_count: 10,
        latest_timestamp: timestamp
      }
      Rails.cache.write("device:#{device_id}", existing_data)

      request = DeviceReadingRequest.new(
        id: device_id,
        readings: [{ timestamp: timestamp, count: 10 }]
      )

      # Use an RSpec spy to check if Rails.cache.write is called
      allow(Rails.cache).to receive(:write).and_call_original

      DeviceReadingService.store_readings(request)
      expect(Rails.cache).not_to have_received(:write)
    end
  end

  describe '.latest_timestamp' do
    it 'returns the latest timestamp from the cache' do
      test_timestamp = Time.now.utc.iso8601
      data = {
        readings: {},
        cumulative_count: 10,
        latest_timestamp: test_timestamp
      }
      Rails.cache.write("device:#{device_id}", data)

      expect(DeviceReadingService.latest_timestamp(device_id)).to eq(test_timestamp)
    end

    it 'returns nil if no data in the cache' do
      expect(DeviceReadingService.latest_timestamp(device_id)).to be_nil
    end
  end

  describe '.cumulative_count' do
    it 'returns the cumulative_count from the cache' do
      data = {
        readings: {},
        cumulative_count: 42,
        latest_timestamp: Time.now.utc.iso8601
      }
      Rails.cache.write("device:#{device_id}", data)

      expect(DeviceReadingService.cumulative_count(device_id)).to eq(42)
    end

    it 'returns 0 if no device data in cache' do
      expect(DeviceReadingService.cumulative_count(device_id)).to eq(0)
    end
  end
end
