require 'rails_helper'

describe 'shorts', type: :request do
  describe 'lookup' do
    subject { get("/#{short_id}") }

    context 'when no short found' do
      let(:short_id) { 'fake' }

      it 'renders a 404' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when short found' do
      let(:short_id) { 'real' }

      it 'redirects to long url', :skip do
        subject
        expect(response).to redirect_to(health_path)
      end
    end
  end
end
