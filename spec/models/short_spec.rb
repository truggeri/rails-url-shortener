# == Schema Information
#
# Table name: shorts
#
#  id             :bigint           not null, primary key
#  full_url       :string           not null
#  short_url      :string           not null
#  user_generated :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_shorts_on_short_url  (short_url)
#
require 'rails_helper'

describe Short, type: :model do
  describe 'validations' do
    subject { object.valid? }

    describe 'full_url' do
      context 'when full_url not provided' do
        let(:object) { Short.new(short_url: 'sho') }

        it 'is invalid' do
          expect(subject).to eq(false)
        end
      end

      context 'when full_url provided' do
        let(:object) { Short.new(full_url: 'something', short_url: 'sho') }

        it 'is valid' do
          expect(subject).to eq(true)
        end
      end
    end

    describe 'short_url' do
      context 'when short_url not provided' do
        let(:object) { Short.new(full_url: 'something') }

        it 'is valid' do
          expect(subject).to eq(true)
        end
      end

      context 'when short_url provided' do
        let(:object)    { Short.new(full_url: 'something', short_url: given_url) }
        let(:given_url) { 'new-url' }

        it 'is valid' do
          expect(subject).to eq(true)
        end

        context 'when short_url has invalid characters' do
          let(:given_url) { 'b@d_Url' }

          it 'is invalid' do
            expect(subject).to eq(false)
          end
        end

        context 'when short_url already taken' do
          it 'is invalid' do
            Short.create(full_url: 'first_one', short_url: given_url)
            expect(subject).to eq(false)
          end
        end
      end
    end
  end

  describe '#marshall' do
    subject { object.marshall }

    let(:object) { Short.create(full_url: 'full-full', short_url: 'shorty') }
    let(:time)   { 4.minutes.ago }

    it 'gives hash respresentation of object' do
      Timecop.freeze(time) do
        expect(subject).to include(created_at: time.iso8601, full_url: 'full-full', short_url: 'shorty')
      end
    end
  end
end
