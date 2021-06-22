require 'rails_helper'

describe 'ops', type: :request do
  describe 'health' do
    subject { get('/health') }

    it 'returns 200' do
      subject
      expect(response).to      have_http_status(:ok)
      expect(response.body).to eq('ok')
    end
  end
end
