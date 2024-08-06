require 'rails_helper'

RSpec.describe "Restaurant API", type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin') }
  let!(:user) {FactoryBot.create(:user, role: 'customer', email: 'customeruser@gmail.com') }
  let!(:restaurant) { FactoryBot.create(:restaurant, user: admin) }
  let!(:food) { FactoryBot.create(:food, restaurant: restaurant) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }
  let(:customer_token) { JsonWebToken.encode(user_id: user.id) }
  
  describe 'GET /api/v2/admin/restaurants' do
    context 'when user is authenticated and its role is admin' do
      before { cookies[:token] = admin_token } 
      it 'returns all restaurants for the admin' do
        admin_only(admin) 
        get '/api/v2/admin/restaurants'
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('All the restaurants of logged in admin')
        expect(json['restaurants'].first['id']).to eq(restaurant.id)
      end
  
      it 'returns no restaurants if none are found' do
        Restaurant.destroy_all
        get '/api/v2/admin/restaurants'
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('No restaurants found for the current admin')
        expect(json['restaurants']).to be_empty
      end
    end

    context 'when user is authenticated but not authorized' do
      before { cookies[:token] = customer_token }
      it 'returns access denied' do
        get '/api/v2/admin/restaurants'
        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq('Access denied')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v2/admin/restaurants'
        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'GET /api/v2/admin/restaurant' do
    context 'when user is authenticated and its role is admin' do
      before { cookies[:token] = admin_token } 
      context 'when the restaurant exists' do
        it 'returns the restaurant details' do
          get "/api/v2/admin/restaurant?id=#{restaurant.id}"
          
          expect(response).to have_http_status(:ok)
          expect(json['message']).to eq('Restaurant details')
          expect(json['restaurant']['id']).to eq(restaurant.id)
        end
      end
  
      context 'when the restaurant does not exist' do
        it 'returns an error' do
          get '/api/v2/admin/restaurant?id=999999'
          
          expect(response).to have_http_status(:not_found)
          expect(json['message']).to eq('Restaurant not found for the given ID')
        end
      end
    end

    context 'when user is authenticated but not authorized' do
      before { cookies[:token] = customer_token }
      it 'returns access denied' do
        get "/api/v2/admin/restaurant?id=#{restaurant.id}"
        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq('Access denied')
      end
    end

    context 'when user is not authenticated' do
      it 'returns access denied' do
        get "/api/v2/admin/restaurant?id=#{restaurant.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'GET /api/v2/admin/foods/restaurant' do
    before { cookies[:token] = admin_token } 
    context 'when foods exist for the restaurant' do
      it 'returns all food items for the restaurant' do
        get "/api/v2/admin/foods/restaurant?id=#{restaurant.id}"
        
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('All the foods of this restaurnat')
        expect(json['foods'].first['id']).to eq(food.id)
      end
    end

    context 'when no foods are found for the restaurant' do
      it 'returns a message indicating no foods' do
        Food.destroy_all

        get "/api/v2/admin/foods/restaurant?id=#{restaurant.id}"
        
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('No food found for the current ID')
        expect(json['foods']).to be_empty
      end
    end
  end

  describe 'POST /api/v2/admin/restaurant/new' do
    before { cookies[:token] = admin_token } 
    let(:valid_params) do
      {
        name: 'New Restaurant',
        location: 'Location',
        pincode: 123456,
        contact_number: '9876543210',
        email: 'new@example.com',
        description: 'Description',
        opening_hours: '9 AM - 9 PM',
        delivery_radius: 10
      }
    end

    context 'when params are valid' do
      it 'creates a new restaurant' do
        post '/api/v2/admin/restaurant/new', params: valid_params
        
        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Restaurant created successfully')
        expect(json['restaurant']['name']).to eq('New Restaurant')
      end
    end

    context 'when params are invalid' do
      it 'returns an error' do
        post '/api/v2/admin/restaurant/new', params: { name: '' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'PATCH /api/v2/admin/restaurant/update' do
    before { cookies[:token] = admin_token } 
    context 'when updating with valid params' do
      it 'updates the restaurant details' do
        patch "/api/v2/admin/restaurant/update", params: { id: restaurant.id, name: 'Updated Restaurant' }
        
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Restaurant details updated successfully')
        expect(json['restaurant']['name']).to eq('Updated Restaurant')
      end
    end

    context 'when updating with invalid params' do
      it 'returns an error if name is blank' do
        patch "/api/v2/admin/restaurant/update", params: { id: restaurant.id, name: '' }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when restaurant does not exist' do
      it 'returns an error' do
        patch "/api/v2/admin/restaurant/update", params: { id: 999999 }
        
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('Restaurant not found')
      end
    end
  end

  describe 'DELETE /api/v2/admin/restaurant/delete' do
    before { cookies[:token] = admin_token } 
    context 'when the restaurant exists' do
      it 'deletes the restaurant' do
        delete "/api/v2/admin/restaurant/delete", params: { id: restaurant.id }
        
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Restaurant successfully deleted')
        expect(Restaurant.exists?(restaurant.id)).to be_falsey
      end
    end

    context 'when the restaurant does not exist' do
      it 'returns an error' do
        delete "/api/v2/admin/restaurant/delete", params: { id: 999999 }
        
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('Restaurant not found')
      end
    end
  end
  def json
    JSON.parse(response.body)
  end
end
