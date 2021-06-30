require 'rails_helper'

describe Suggestion do
  describe 'slug' do
    subject { instance.slug }

    let(:instance) { described_class.new(hostname) }

    context 'when invalid hostname' do
      [nil, ''].each do |bad_hostname|
        context "is #{bad_hostname}" do
          let(:hostname) { bad_hostname }

          it { expect { subject }.to raise_error(ArgumentError) }
        end
      end
    end

    context 'when hostname valid' do
      before { allow(instance).to receive(:rand).and_return(0) }

      context 'when hostname has four unique consants' do
        let(:hostname) { 'goldbelly' }

        it { expect(subject).to eq('gldb') }
      end

      context 'when hostname has less than four unique consants' do
        let(:hostname) { 'google' }

        it { expect(subject).to eq('gloe') }
      end

      context 'when hostname has less than four chars' do
        let(:hostname) { 'hi' }

        it { expect(subject).to eq('hihh') }
      end

      context 'when hostname is full of vowels' do
        let(:hostname) { 'ou' }

        it { expect(subject).to eq('ouoo') }
      end
    end
  end
end
