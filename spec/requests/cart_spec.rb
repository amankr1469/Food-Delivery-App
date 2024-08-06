require 'rails_helper'

RSpec.describe 'Cart API', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:food) { FactoryBot.build(:food) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  
  describe 'POST /api/v2/cart/add' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      context 'with valid food_id' do
        it 'adds the item to the cart' do
          post '/api/v2/cart/add', params: { food_id: food.id }
          expect(response).to have_http_status(:created)
          expect(json['message']).to eq('Item added to cart')
        end
      end

      context 'with invalid food_id' do
        it 'returns an error' do
          post '/api/v2/cart/add', params: { food_id: nil }
          expect(response).to have_http_status(:unauthorized)
          expect(json['message']).to eq('ID invalid')
        end
      end
    end

    context 'when the user is not authenticated' do
      before { cookies.delete(:token)}
      it 'returns an authentication error' do
        post '/api/v2/cart/add', params: { food_id: food.id }

        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /api/v2/cart/remove' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      context 'with valid food_id' do
        before do
          post '/api/v2/cart/add', params: { food_id: food.id }
        end

        it 'removes the item from the cart' do
          post '/api/v2/cart/remove', params: { food_id: food.id }

          expect(response).to have_http_status(:created)
          expect(json['message']).to eq('Item removed from cart.')
        end
      end

      context 'with invalid food_id' do
        it 'returns an error' do
          post '/api/v2/cart/remove', params: { food_id: nil }

          expect(response).to have_http_status(:unauthorized)
          expect(json['message']).to eq('ID invalid')
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an authentication error' do
        post '/api/v2/cart/remove', params: { food_id: food.id }

        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'GET /api/v2/cart' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      it 'returns the cart items' do
        post '/api/v2/cart/add', params: { food_id: food.id }
        get '/api/v2/cart'
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Cart Items')
        # expect(json['food_items']).to be_present
        expect(json['quantities']).to be_present
      end

      # context 'when the food ID in cart is nil' do
        # it 'returns the cart items' do
        #   post '/api/v2/cart/add', params: { food_id: nil }
        #   get '/api/v2/cart'
        #   expect(response).to have_http_status(:ok)
        #   expect(json['message']).to eq('Cart Items')
        #   expect(json['missing_items']).to be_present
        # end
      # end
    end

    context 'when the user is not authenticated' do
      it 'returns an authentication error' do
        get '/api/v2/cart'

        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /api/v2/cart/checkout' do
    context 'when the user is authenticated' do
      before do 
        cookies[:token] = token 
      end
      before do
        post '/api/v2/cart/add', params: { food_id: food.id }
      end

      context 'with a valid address' do
        it 'checks out the cart' do
          post '/api/v2/cart/checkout', params: { address: '123 Main St' }

          expect(response).to have_http_status(:created)
          expect(json['message']).to eq('Order placed successfully')
        end
      end

      context 'with an empty cart' do
        before do
          post '/api/v2/cart/remove', params: { food_id: food.id }
        end

        it 'returns an error' do
          post '/api/v2/cart/checkout', params: { address: '123 Main St' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['message']).to eq('Cart is empty')
        end
      end

      context 'with an invalid address' do
        it 'returns an error' do
          post '/api/v2/cart/checkout', params: { address: '' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['message']).to eq("Address can't be blank")
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an authentication error' do
        post '/api/v2/cart/checkout', params: { address: '123 Main St' }

        expect(response).to have_http_status(:unauthorized)
        expect(json['message']).to eq('Unauthorized')
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
