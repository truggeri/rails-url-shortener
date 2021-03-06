# == Schema Information
#
# Table name: shorts
#
#  id             :bigint           not null, primary key
#  cost           :integer          not null
#  full_url       :string           not null
#  short_url      :string           not null
#  user_generated :boolean          default(FALSE), not null
#  uuid           :uuid             not null
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

        it { expect(subject).to eq(false) }
      end

      context 'when invalid full_url provided' do
        let(:object) { Short.new(full_url: '<something>', short_url: 'sho') }

        it { expect(subject).to eq(false) }
      end

      context 'when full_url is too short' do
        let(:object) { Short.new(full_url: 'so', short_url: 'sho') }

        it { expect(subject).to eq(false) }
      end

      context 'when valid full_url provided' do
        let(:object) { Short.new(full_url: 'something', short_url: 'shor') }

        it { expect(subject).to eq(true) }
      end
    end

    describe 'short_url' do
      context 'when short_url not provided' do
        let(:object) { Short.new(full_url: 'something') }

        it { expect(subject).to eq(true) }
      end

      context 'when short_url provided' do
        let(:object) { Short.new(full_url: 'something', short_url: given_url) }

        context 'when short_url has valid characters' do
          let(:given_url) { 'g00d_URL-' }

          it { expect(subject).to eq(true) }
        end

        context 'when short_url has invalid characters' do
          let(:given_url) { 'b@d_Url' }

          it { expect(subject).to eq(false) }
        end

        context 'when short_url is too short' do
          let(:given_url) { 'goo' }

          it { expect(subject).to eq(false) }
        end

        context 'when short_url is a reserved word' do
          let(:given_url) { Short::RESERVED_SHORTS.sample }

          it { expect(subject).to eq(false) }
        end

        context 'when short_url already taken' do
          let(:given_url) { 'new-url' }

          it 'is invalid' do
            Short.create(full_url: 'first_one', short_url: given_url)
            expect(subject).to eq(false)
          end
        end
      end
    end
  end

  describe 'generate_short' do
    subject { object.short_url }

    context 'when short_url already exists' do
      let(:object) { Short.create(full_url: 'full', short_url: 'shorty') }

      it 'doesn\'t change' do
        expect(subject).to eq('shorty')
      end
    end

    context 'when short_url isn\'t given' do
      let(:object) { Short.create(full_url: 'full', short_url: nil) }

      it 'has a randomly generated code' do
        expect(subject).not_to eq(nil)
      end

      context 'when auto generated code is already taken' do
        let(:slug) { instance_double('slug', generate: 'taken') }
        before do
          allow(Slug).to receive(:new).and_return(slug).once
          allow(Slug).to receive(:new).and_call_original
        end

        it 'has a randomly generated code' do
          Short.create(full_url: 'full', short_url: 'taken')
          expect(subject).not_to eq(nil)
          expect(subject).not_to eq('taken')
        end
      end

      context 'when all random codes are taken (at least ten)' do
        let(:slug)         { instance_double('slug') }
        let(:taken_values) { %w[azza bzza czza dzza ezza fzza gzza hzza izza jzza kzza] }

        before do
          allow(Slug).to receive(:new).and_return(slug)
          allow(slug).to receive(:generate).and_return(*taken_values)
        end

        it 'gives up and can\'t create code' do
          taken_values.each do |v|
            Short.create(full_url: 'full', short_url: v)
          end
          expect(subject).to       eq(nil)
          expect(object.valid?).to eq(false)
        end
      end
    end
  end

  describe 'calculate_cost' do
    subject { object.cost }

    context 'when cost present' do
      let(:object)     { Short.create(full_url: 'full', cost: given_cost) }
      let(:given_cost) { rand(1..15) }

      it 'keeps the original' do
        expect(subject).to eq(given_cost)
      end

      context 'when cost 0' do
        let(:given_cost) { 0 }

        it 'is invalid' do
          expect(object.valid?).to eq(false)
        end
      end
    end

    context 'when cost empty' do
      let(:object) { Short.create(full_url: 'full', short_url: given_short) }

      { 'goly' => 5, 'oely' => 6, 'gole' => 6, 'b-b_' => 9 }.each do |short, exp_cost|
        context "when short '#{short}'" do
          let(:given_short) { short }

          it { expect(subject).to eq(exp_cost) }
        end
      end
    end
  end

  describe 'generate_uuid' do
    subject { object.uuid }

    context 'when uuid present' do
      let(:object)     { Short.create(full_url: 'full', uuid: given_uuid) }
      let(:given_uuid) { SecureRandom.uuid }

      it 'keeps the original' do
        expect(subject).to eq(given_uuid)
      end
    end

    context 'when uuid absent' do
      let(:object) { Short.create(full_url: 'full') }

      it 'generates one' do
        expect(subject).not_to eq(nil)
      end
    end
  end

  describe '#marshall' do
    subject { object.marshall }

    let(:object) { Short.create(full_url: 'full-full', short_url: 'shorty') }
    let(:time)   { 4.minutes.ago }

    it 'gives hash respresentation of object' do
      Timecop.freeze(time) do
        allow(Token).to receive(:encode).with({ iat: object.created_at.to_i, uuid: object.uuid })
                                        .and_return('fake-token')
        expect(subject).to include(cost:       7,
                                   created_at: time.iso8601,
                                   full_url:   'full-full',
                                   short_url:  'shorty',
                                   token:      'fake-token')
      end
    end
  end
end
