require 'rails_helper'

RSpec.describe "Food API", type: :request do
  let!(:admin) { FactoryBot.create(:user, role: 'admin') }
  let!(:user) { FactoryBot.create(:user, role: 'customer', email: 'customeruser@gmail.com') }
  let!(:restaurant) { FactoryBot.create(:restaurant, user: admin) }
  let!(:food) { FactoryBot.create(:food, restaurant: restaurant) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }
  let(:customer_token) { JsonWebToken.encode(user_id: user.id) }
  
  describe 'GET /api/v2/admin/food' do
    context 'when user is authenticated and its role is admin' do
      before { cookies[:token] = admin_token }

      it 'returns food item details' do
        get "/api/v2/admin/food?id=#{food.id}"
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Food item details')
        expect(json['food']['id']).to eq(food.id)
      end

      it 'returns error if food item not found' do
        get "/api/v2/admin/food?id=nonexistent_id"
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('Food item not found')
      end
    end

    context 'when user is authenticated but not authorized' do
      before { cookies[:token] = customer_token }
      
      it 'returns access denied' do
        get "/api/v2/admin/food?id=#{food.id}"
        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq('Access denied')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get "/api/v2/admin/food?id=#{food.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'PATCH /api/v2/admin/food/update' do
    context 'when user is authenticated and its role is admin' do
      before { cookies[:token] = admin_token }

      it 'updates food item details' do
        patch '/api/v2/admin/food/update', params: {
          id: food.id,
          name: 'Updated Food Name',
          price: 20
        }
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Food item details updated successfully')
        expect(json['food']['name']).to eq('Updated Food Name')
        expect(json['food']['price']).to eq(20)
      end

      it 'returns error if food item not found' do
        patch '/api/v2/admin/food/update', params: {
          id: 'nonexistent_id',
          name: 'Updated Food Name'
        }
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('Food item not found')
      end

      it 'returns error if validation fails' do
        patch '/api/v2/admin/food/update', params: {
          id: food.id,
          price: ''
        }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is authenticated but not authorized' do
      before { cookies[:token] = customer_token }
      
      it 'returns access denied' do
        patch '/api/v2/admin/food/update', params: {
          id: food.id,
          name: 'Updated Food Name'
        }
        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq('Access denied')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        patch '/api/v2/admin/food/update', params: {
          id: food.id,
          name: 'Updated Food Name'
        }
        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'DELETE /api/v2/admin/food/delete' do
    context 'when user is authenticated and its role is admin' do
      before { cookies[:token] = admin_token }

      it 'deletes the food item' do
        delete "/api/v2/admin/food/delete?id=#{food.id}"
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Food item successfully deleted')
        expect(Food.find_by(id: food.id)).to be_nil
      end

      it 'returns error if food item not found' do
        delete "/api/v2/admin/food/delete?id=nonexistent_id"
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('Food item not found')
      end
    end

    context 'when user is authenticated but not authorized' do
      before { cookies[:token] = customer_token }
      
      it 'returns access denied' do
        delete "/api/v2/admin/food/delete?id=#{food.id}"
        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq('Access denied')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        delete "/api/v2/admin/food/delete?id=#{food.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /api/v2/admin/food/new' do
    context 'when user is authenticated and its role is admin' do
      before { cookies[:token] = admin_token }

      it 'creates a new food item' do
        post '/api/v2/admin/food/new', params: {
          name: 'New Food',
          description: 'Delicious food item with aura +1000',
          price: 15,
          category: 'Dessert',
          restaurant_id: restaurant.id
        }
        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Food item created successfully')
        expect(json['food']['name']).to eq('New Food')
      end

      it 'returns error if required params are missing' do
        post '/api/v2/admin/food/new', params: {
          name: 'New Food'
        }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when user is authenticated but not authorized' do
      before { cookies[:token] = customer_token }
      
      it 'returns access denied' do
        post '/api/v2/admin/food/new', params: {
          name: 'New Food',
          description: 'Delicious',
          price: 15.5,
          category: 'Dessert',
          restaurant_id: restaurant.id
        }
        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq('Access denied')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        post '/api/v2/admin/food/new', params: {
          name: 'New Food',
          description: 'Delicious',
          price: 15.5,
          category: 'Dessert',
          restaurant_id: restaurant.id
        }
        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end
  def json
    JSON.parse(response.body)
  end
end
