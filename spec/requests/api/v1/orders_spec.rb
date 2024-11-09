require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do
  let(:user) { create(:user) }
  let!(:btc_wallet) { create(:wallet, user: user, currency: 'btc', balance: 10) }
  let!(:usd_wallet) { create(:wallet, user: user, currency: 'usd', balance: 100000) }

  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe 'POST /orders/create' do
    context 'when creating a sell order' do
      it 'successfully creates a sell order and debits the wallet' do
        post '/api/v1/orders/create',
             params: { order: { side: 'sell', base_currency: 'btc', quote_currency: 'usd', price: 50000, volume: 1 } },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['payload']['side']).to eq('sell')
        expect(json['payload']['volume']).to eq("1.0")
        expect(json['payload']['state']).to eq('pending')

        btc_wallet.reload
        expect(btc_wallet.balance.to_i).to eq(9)
      end
    end

    context 'when creating a buy order' do
      it 'successfully creates a buy order and debits the wallet' do
        post '/api/v1/orders/create',
             params: { order: { side: 'buy', base_currency: 'btc', quote_currency: 'usd', price: 50000, volume: 0.1 } },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['payload']['side']).to eq('buy')
        expect(json['payload']['volume']).to eq("0.1")
        expect(json['payload']['state']).to eq('pending')

        usd_wallet.reload
        expect(usd_wallet.balance.to_i).to eq(95000)
      end
    end

    context 'when the user does not have enough funds for a buy order' do
      it 'returns an error when there is insufficient balance' do
        post '/api/v1/orders/create',
             params: { order: { side: 'buy', base_currency: 'btc', quote_currency: 'usd', price: 100000, volume: 2 } },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
        expect(json['message']).to eq('Insufficient funds')
      end
    end

    context 'when the user tries to sell more than they own' do
      it 'returns an error when there is insufficient balance for the sell order' do
        post '/api/v1/orders/create',
             params: { order: { side: 'sell', base_currency: 'btc', quote_currency: 'usd', price: 50000, volume: 20 } },
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
        expect(json['message']).to eq('Insufficient funds')
      end
    end
  end

  describe 'PUT /orders/cancel' do
    let!(:order) { create(:order, user: user, side: 'sell', base_currency: 'btc', quote_currency: 'usd', price: 50000, volume: 1, state: 'pending') }

    context 'when the order exists and is pending' do
      it 'successfully cancels the order and credits the funds back' do
        put '/api/v1/orders/cancel', params: { order_id: order.id }, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(json['status']).to eq('success')
        expect(json['message']).to eq('Successfully cancelled')

        btc_wallet.reload
        expect(btc_wallet.balance.to_i).to eq(11)
      end
    end

    context 'when the order does not exist' do
      it 'returns an error if the order is not found' do
        put '/api/v1/orders/cancel', params: { order_id: 9999 }, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
        expect(json['message']).to eq('Order not found or cannot be cancelled')
      end
    end

    context 'when the order is not pending' do
      it 'returns an error if the order is already completed or cancelled' do
        order.update(state: 'completed')

        put '/api/v1/orders/cancel', params: { order_id: order.id }, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['status']).to eq('error')
        expect(json['message']).to eq('Order not found or cannot be cancelled')
      end
    end
  end
end
