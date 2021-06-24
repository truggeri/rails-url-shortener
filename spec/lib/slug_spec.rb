require 'rails_helper'

describe Slug do
  subject { Slug.new(number).generate }

  context 'when number is nil' do
    let(:number) { nil }

    it { expect { subject }.to raise_error(ArgumentError) }
  end

  context 'when number is too large' do
    let(:number) { 64**6 + 1 }

    it { expect { subject }.to raise_error(ArgumentError) }
  end

  context 'when number is too small' do
    let(:number) { -1 }

    it { expect { subject }.to raise_error(ArgumentError) }
  end

  expectations = { 602_023_732 => 'zyQU0s', 6_234_023_784 => 'PWEA5t', 0 => '000000', 1 => '001000', 293 => '00B004' }
  expectations.each do |input, output|
    context "when number is '#{input}'" do
      let(:number) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
