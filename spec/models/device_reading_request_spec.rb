require 'rails_helper'

RSpec.describe DeviceReadingRequest, type: :model do
  describe 'validations' do
    context 'when all attributes are valid' do
      it 'is valid' do
        request = DeviceReadingRequest.new(
          id: '36d5658a-6908-479e-887e-a949ec199272',
          readings: [
            { timestamp: '2021-09-29T16:08:15+01:00', count: 2 },
            { timestamp: '2021-09-29T16:09:15+01:00', count: 15 }
          ]
        )
        expect(request).to be_valid
      end
    end

    context 'when id is missing' do
      it 'is invalid' do
        request = DeviceReadingRequest.new(
          id: nil,
          readings: [
            { timestamp: '2021-09-29T16:08:15+01:00', count: 2 }
          ]
        )
        expect(request).not_to be_valid
        expect(request.errors[:id]).to include("can't be blank")
      end
    end

    context 'when readings is missing or not an array' do
      it 'is invalid if readings is nil' do
        request = DeviceReadingRequest.new(
          id: '36d5658a-6908-479e-887e-a949ec199272',
          readings: nil
        )
        expect(request).not_to be_valid
        expect(request.errors[:readings]).to include('must be an array and cannot be empty')
      end

      it 'is invalid if readings is not an array' do
        request = DeviceReadingRequest.new(
          id: '36d5658a-6908-479e-887e-a949ec199272',
          readings: { timestamp: 'invalid', count: 5 }
        )
        expect(request).not_to be_valid
        expect(request.errors[:readings]).to include('must be an array and cannot be empty')
      end
    end

    context 'when inner readings are invalid' do
      it 'adds errors for invalid timestamps or counts' do
        # Missing timestamp, invalid count
        request = DeviceReadingRequest.new(
          id: '36d5658a-6908-479e-887e-a949ec199272',
          readings: [
            { timestamp: nil, count: 5 },
            { timestamp: 'not-an-iso8601-date', count: 10 },
            { timestamp: '2021-09-29T16:09:15+01:00', count: '5.5' }
          ]
        )

        expect(request).not_to be_valid
        expect(request.errors[:readings].size).to be >= 3
      end
    end
  end
end
