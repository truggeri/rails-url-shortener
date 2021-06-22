require 'rails_helper'

describe 'shorts', type: :request do
  describe 'show' do
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

      it 'redirects to long url' do
        Short.create(short_url: 'real', full_url: 'http://original_url')
        subject
        expect(response).to redirect_to('http://original_url')
      end
    end
  end

  describe 'create' do
    subject { post('/', params: params) }

    let(:params) { {} }

    context 'when user not logged in', :skip do
      it 'gives unauthorized' do
        expect { subject }.not_to change(Short, :count)
        expect(response).to       have_http_status(:unauthorized)
      end
    end

    context 'when params are empty' do
      let(:params) { {} }

      it 'gives bad request' do
        expect { subject }.not_to change(Short, :count)
        expect(response).to       have_http_status(:bad_request)
      end
    end

    context 'when params only contain full_url' do
      let(:params) { { full_url: 'something' } }

      it 'creates new short' do
        expect { subject }.to change(Short, :count).by(1)
        expect(response).to   have_http_status(:ok)

        last_short = Short.last
        expect(last_short.full_url).to       eq('something')
        expect(last_short.short_url).not_to  eq(nil)
        expect(last_short.user_generated).to eq(false)
      end
    end

    context 'when params are full' do
      let(:params) { { full_url: 'something', short_url: 'SoM' } }

      it 'creates new short' do
        expect { subject }.to change(Short, :count).by(1)
        expect(response).to   have_http_status(:ok)

        last_short = Short.last
        expect(last_short.full_url).to       eq('something')
        expect(last_short.short_url).to      eq('som')
        expect(last_short.user_generated).to eq(true)
      end

      context 'when create fails' do
        before { allow(Short).to receive(:create).and_return(Short.new) }

        it 'gives bad request' do
          expect { subject }.not_to change(Short, :count)
          expect(response).to       have_http_status(:bad_request)
        end
      end
    end
  end

  describe 'destroy' do
    subject { delete("/#{short_id}") }

    context 'when user not logged in', :skip do
      it 'gives unauthorized' do
        expect { subject }.not_to change(Short, :count)
        expect(response).to       have_http_status(:unauthorized)
      end
    end

    context 'when user logged in' do
      context 'when given id is bad' do
        let(:short_id) { 'bad-id' }

        it 'gives not found' do
          expect { subject }.not_to change(Short, :count)
          expect(response).to       have_http_status(:not_found)
        end
      end

      context 'when given id is good' do
        let(:short_id) { 'good-id' }
        let!(:short)   { Short.create(short_url: short_id, full_url: 'something') }

        it 'removes short' do
          expect { subject }.to change(Short, :count).by(-1)
          expect(response).to   have_http_status(:ok)
        end

        context 'when destroy fails' do
          before { allow_any_instance_of(Short).to receive(:destroy).and_return(false) }

          it 'gives bad request' do
            subject
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end
  end
end
