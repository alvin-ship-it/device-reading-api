class ReadingInput
  include ActiveModel::Model

  attr_accessor :timestamp, :count

  validates :timestamp, presence: true
  validate :timestamp_must_be_iso8601

  validates :count, presence: true,
                    numericality: { only_integer: true }

  private

  def timestamp_must_be_iso8601
    # Skip if it's already blank; presence validation will handle that error
    return if timestamp.blank?

    begin
      Time.iso8601(timestamp)
    rescue ArgumentError
      errors.add(:timestamp, 'must be a valid ISO-8601 date-time string')
    end
  end
end
  