require 'rails_helper'

RSpec.describe "Api::V1::Wallets", type: :request do
  let(:user) { create(:user) }
  let!(:btc_wallet) { create(:wallet, user: user, currency: 'btc', balance: 0) }
  let!(:usd_wallet) { create(:wallet, user: user, currency: 'usd', balance: 1000) }

  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe 'POST /wallets/deposit' do
    context 'when the user deposits funds into their wallet' do
      it 'successfully deposits funds and updates the wallet balance' do
        post '/api/v1/wallets/deposit',
             params: { currency: 'btc', amount: 5 },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['payload']['currency']).to eq('btc')
        expect(json['payload']['balance']).to eq("5.0")
      end
    end

    context 'when the deposit amount is invalid' do
      it 'returns an error if the deposit amount is zero or negative' do
        post '/api/v1/wallets/deposit',
             params: { currency: 'btc', amount: -1 },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
      end
    end
  end

  describe 'POST /wallets/withdrawal' do
    context 'when the user withdraws funds from their wallet' do
      it 'successfully withdraws funds and updates the wallet balance' do
        post '/api/v1/wallets/withdrawal',
             params: { currency: 'usd', amount: 500 },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['payload']['currency']).to eq('usd')
        expect(json['payload']['balance']).to eq("500.0")
      end
    end

    context 'when the user attempts to withdraw more than their balance' do
      it 'returns an error if the withdrawal amount exceeds the balance' do
        post '/api/v1/wallets/withdrawal',
             params: { currency: 'usd', amount: 1500 },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
      end
    end

    context 'when the withdrawal amount is invalid' do
      it 'returns an error if the withdrawal amount is zero or negative' do
        post '/api/v1/wallets/withdrawal',
             params: { currency: 'usd', amount: -1 },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
      end
    end
  end

  describe 'GET /wallets/balances' do
    context 'when the user retrieves their wallet balances' do
      it 'returns the correct wallet balances for all currencies' do
        get '/api/v1/wallets/balances', headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['payload'].size).to eq(2)
        expect(json['payload']).to include(
          { 'currency' => 'btc', 'balance' => "0.0" },
          { 'currency' => 'usd', 'balance' => "1000.0" }
        )
      end
    end
  end
end
