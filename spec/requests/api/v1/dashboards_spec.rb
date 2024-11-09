require 'rails_helper'

RSpec.describe 'Api::V1::Dashboards', type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:normal_user) { create(:user) }

  describe 'GET /dashboards/index' do
    context 'when the user is an admin' do
      it 'returns the dashboard data' do
        token = JsonWebToken.encode(user_id: admin_user.id)
        get '/api/v1/dashboards/index', headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        expect(json['status']).to eq('success')
      end
    end

    context 'when the user is not an admin' do
      it 'returns an unauthorized error' do
        token = JsonWebToken.encode(user_id: normal_user.id)
        get '/api/v1/dashboards/index', headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unauthorized)
        expect(json['status']).to eq('error')
        expect(json['message']).to eq('Not authorized')
      end
    end
  end
end
