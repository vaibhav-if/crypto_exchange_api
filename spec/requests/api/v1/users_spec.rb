require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/users/signup" do
    it "signs up a user" do
      post "/api/v1/users/signup", params: { user: { email: "test@example.com", password: "password" } }
      expect(response).to have_http_status(:success)
      expect(json['status']).to eq('success')
    end
  end

  describe "POST /api/v1/users/login" do
    it "logs in a user" do
      post "/api/v1/users/login", params: { user: { email: user.email, password: "password" } }
      expect(response).to have_http_status(:success)
      expect(json['status']).to eq('success')
      expect(json['payload']['token']).not_to be_nil
    end
  end
end
