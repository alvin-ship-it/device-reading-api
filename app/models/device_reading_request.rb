class DeviceReadingRequest
  include ActiveModel::Model

  attr_accessor :id, :readings

  validates :id, presence: true
  validate :readings_must_be_valid

  ## Custom validation for readings
  def readings_must_be_valid
    if readings.blank? || !readings.is_a?(Array)
      errors.add(:readings, 'must be an array and cannot be empty')
      return
    end

    readings.each do |reading_hash|
      reading = ReadingInput.new(reading_hash)
      unless reading.valid?
        reading.errors.full_messages.each do |msg|
          errors.add(:readings, msg)
        end
      end
    end
  end
end
  