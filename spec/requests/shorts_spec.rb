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
        expect(response).to   have_http_status(:created)

        last_short = Short.last
        expect(last_short.full_url).to       eq('something')
        expect(last_short.short_url).not_to  eq(nil)
        expect(last_short.user_generated).to eq(false)
      end
    end

    context 'when params are full' do
      let(:params) { { full_url: 'something', short_url: 'SoMe' } }

      it 'creates new short' do
        expect { subject }.to change(Short, :count).by(1)
        expect(response).to   have_http_status(:created)

        last_short = Short.last
        expect(last_short.full_url).to       eq('something')
        expect(last_short.short_url).to      eq('some')
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
    subject { delete("/#{short_id}", headers: headers) }

    let(:short_id) { 'this-shouldnt-matter' }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('JWT_SECRET').and_return('test-secret')
    end

    shared_examples_for 'an unauthorized request' do
      it 'gives unauthorized' do
        expect { subject }.not_to change(Short, :count)
        expect(response).to       have_http_status(:unauthorized)
      end
    end

    context 'when no authorizaion header' do
      let(:headers)  { {} }

      it_behaves_like 'an unauthorized request'
    end

    context 'when token given' do
      let(:headers) { { 'Authorization' => "bearer #{given_token}" } }

      context 'when token is junk' do
        let(:given_token) { 'a.b.c' }

        it_behaves_like 'an unauthorized request'
      end

      context 'when token is not from this issuer' do
        let(:given_token) do
          'eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.' \
          'eyJpYXQiOjE2MjQ0NTY1NjUsImlzcyI6InNvbWVib2R5X2Vsc2UiLCJ1dWlkIjoiYS1iLWMifQ.' \
          'XxpZNPUShbvEaNWvqkU3VgpNbyfqruRdPM2GmXNVR80'
        end

        it_behaves_like 'an unauthorized request'
      end

      context 'when token doesn\'t have uuid' do
        let(:given_token) do
          'eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MjQ0NTczMDUsImlzcyI6InJhaWxzLXVybC1zaG9ydGVuZXIifQ.' \
          '-bW-W3q-58wvsus88fkgfcBJ3gzYeNlri3pqtvnaeG4'
        end

        it_behaves_like 'an unauthorized request'
      end

      context 'when given id is bad' do
        let(:short_id)    { 'bad-id' }
        let(:given_token) { Token.encode({ uuid: 'something' }) }

        it 'gives not found' do
          expect { subject }.not_to change(Short, :count)
          expect(response).to       have_http_status(:not_found)
        end
      end

      context 'when given id is good' do
        let(:short_id)   { 'good-id' }
        let!(:short)     { Short.create(short_url: short_id, full_url: 'something', uuid: given_uuid) }
        let(:given_uuid) { '7fb83e82-943d-42bf-ae34-71290723a9cf' }

        context 'when token has a different shorts uuid' do
          let(:other_short) { Short.create(short_url: 'other', full_url: 'somethingelse', uuid: other_uuid) }
          let(:other_uuid)  { '18d03576-2a73-4c09-b4da-6bf145d0981d' }
          let(:given_token) { Token.encode({ uuid: other_uuid, iat: short.created_at.to_i }) }

          it_behaves_like 'an unauthorized request'
        end

        context 'when token is good' do
          let(:given_token) { Token.encode({ uuid: given_uuid, iat: short.created_at.to_i }) }

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

  describe '#suggest' do
    subject { post('/suggestion', params: params) }

    let(:params) { {} }

    context 'when params are empty' do
      let(:params) { {} }

      it 'gives bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when given hostname is malformed' do
      let(:params) { { full_url: 'email@something.com' } }

      it 'gives bad request' do
        expect(Suggestion).not_to receive(:new)
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when params contain full_url' do
      let(:params)          { { full_url: 'https://www.something.com/foo' } }
      let(:mock_suggestion) { instance_double(Suggestion) }

      it 'suggests a short' do
        allow(Suggestion).to      receive(:new).with('something').and_return(mock_suggestion)
        allow(mock_suggestion).to receive(:slug).and_return('smth')
        subject
        expect(response).to      have_http_status(:ok)
        expect(response.body).to eq({ hostname: 'something', short: 'smth' }.to_json)
      end
    end
  end

  describe '#count' do
    subject { get('/count') }

    before { Short.all.each(&:destroy) }

    shared_examples_for 'a successful count request' do
      it do
        subject
        expect(response).to      have_http_status(:ok)
        expect(response.body).to eq({ count: expected_count }.to_json)
      end
    end

    context 'when no shorts' do
      it_behaves_like 'a successful count request' do
        let(:expected_count) { 0 }
      end
    end

    context 'when one short' do
      before { Short.create(full_url: 'something1') }

      it_behaves_like 'a successful count request' do
        let(:expected_count) { 1 }
      end
    end

    context 'when multipe shorts' do
      let(:count) { Random.rand(2..5) }

      before do
        (1..count).each do |i|
          Short.create(full_url: "something#{i}")
        end
      end

      it_behaves_like 'a successful count request' do
        let(:expected_count) { count }
      end
    end
  end
end
