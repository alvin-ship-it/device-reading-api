class DeviceReadingService
  # Store readings in the in-memory cache.
  #
  # This method updates:
  #   - device_data[:readings]: a Hash of timestamp => count
  #   - device_data[:cumulative_count]: sum of all unique counts
  #   - device_data[:latest_timestamp]: string of the most recent timestamp
  #
  # It will only write back to the cache if any new readings were added.
  def self.store_readings(device_request)
    device_id   = device_request.id
    device_data = Rails.cache.fetch(cache_key(device_id)) || default_device_data
    updated     = false

    device_request.readings.each do |reading|
      timestamp_str = reading[:timestamp]
      count_val     = reading[:count].to_i

      # Skip if we already have this timestamp (avoid duplicates).
      next if device_data[:readings].key?(timestamp_str)

      # Mark that we made changes
      updated = true

      device_data[:readings][timestamp_str] = count_val
      device_data[:cumulative_count]       += count_val

      # Update latest timestamp if the current reading is newer
      if device_data[:latest_timestamp].nil? || (timestamp_str > device_data[:latest_timestamp])
        device_data[:latest_timestamp] = timestamp_str
      end
    end

    # Only write back to the cache if at least one new reading was added
    Rails.cache.write(cache_key(device_id), device_data) if updated
  end

  def self.latest_timestamp(device_id)
    (Rails.cache.read(cache_key(device_id)) || {})[:latest_timestamp]
  end

  def self.cumulative_count(device_id)
    (Rails.cache.read(cache_key(device_id)) || {})[:cumulative_count] || 0
  end

  private

  def self.cache_key(device_id)
    "device:#{device_id}"
  end

  def self.default_device_data
    {
      readings: {},
      cumulative_count: 0,
      latest_timestamp: nil
    }
  end
end
