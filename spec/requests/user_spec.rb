require 'rails_helper'

RSpec.describe 'User API', type: :request do
  let!(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password', name: 'Test User', contact_number: '1234567890') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe 'GET /v2/user/profile' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      it 'returns user profile details' do
        get '/api/v2/user/profile'
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('User Details')
        expect(JSON.parse(response.body)['user']['email']).to eq('test@example.com')
      end
    end

    context 'when the user is not authenticated' do
      before { cookies.delete(:token)}
      it 'returns an unauthorized error' do
        get '/api/v2/user/profile'
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'DELETE /v2/user/logout' do
    before do 
      cookies[:token] = token 
    end
    it 'logs out the user' do
      delete '/api/v2/user/logout'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end
  end

  describe 'PATCH /v2/user/update' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      it 'updates user details with valid data' do
        patch '/api/v2/user/update', params: { email: 'newemail@example.com', name: 'New Name', contact_number: '0987654321' }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('User details updated')
        expect(user.reload.email).to eq('newemail@example.com')
        expect(user.reload.name).to eq('New Name')
        expect(user.reload.contact_number).to eq('0987654321')
      end
    end

    context 'when the user is not authenticated' do
      before { cookies.delete(:token) }

      it 'returns an unauthorized error' do
        patch '/api/v2/user/update', params: { email: 'newemail@example.com', name: 'New Name' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'DELETE /v2/user/delete' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      it 'deletes the user account' do
        delete '/api/v2/user/delete'
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('User was successfully destroyed')
        expect(User.find(user.id)).to be_nil
      end
    end

    context 'when the user is not authenticated' do
      before { cookies.delete(:token) }

      it 'returns an unauthorized error' do
        delete '/api/v2/user/delete'
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Unauthorized')
      end
    end
  end
end
