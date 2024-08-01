require 'spec_helper'

RSpec.describe 'Home API', type: :request do
  let!(:restaurant) { FactoryBot.create(:restaurant, name: 'Test Restaurant', description: 'Test Description') }
  let!(:food) { FactoryBot.create(:food, name: 'Test Food', price: 100, restaurant: restaurant) }

  describe 'GET /api/v2/index' do
    context 'when called without parameters' do
      it 'returns home page with restaurants and foods' do
        get '/api/v2/index'

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Home Page with Restaurants and Foods')
        expect(json['restaurant']).to be_present
        expect(json['food']).to be_present
      end
    end
  end

  describe 'GET /api/v2/index' do
    context 'when called with correct parameters' do
      it 'returns home page data' do
        get '/api/v2/index', params: { limit: 10, offset: 0 }
  
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Home Page with Restaurants and Foods')
        expect(json['restaurant']).to be_present
        expect(json['food']).to be_present
      end
    end
  end

  #TODO - Improve logic
  describe 'GET /api/v2/index' do
    context 'when called with more than set limit' do
      it 'returns home page data' do
        get '/api/v2/index', params: { limit: 999, offset: 0 }
  
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Home Page with Restaurants and Foods')
        expect(json['restaurant'].size).to be <= 100
        expect(json['food'].size).to be <= 100
      end
    end
  end

  describe 'GET /api/v2/search' do
    context 'when search query is present' do
      it 'returns search results' do
        get '/api/v2/search', params: { q: 'Test' }
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Search results')
        expect(json['results']['restaurants']).to_not be_empty
        expect(json['results']['foods']).to_not be_empty
      end
    end

    context 'when search query is absent' do
      it 'returns an error' do
        get '/api/v2/search'
        expect(response).to have_http_status(:bad_request)
        expect(json['error']).to eq('q is missing')
      end
    end
  end

  describe 'GET /api/v2/search/restaurants' do
    context 'when search query is present' do
      it 'returns search results for restaurants' do
        get '/api/v2/search/restaurants', params: { q: 'Test' }
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Search results')
        expect(json['results']).to_not be_empty
      end
    end

    context 'when search query is absent' do
      it 'returns an error' do
        get '/api/v2/search/restaurants'
        expect(response).to have_http_status(:bad_request)
        expect(json['error']).to eq('q is missing')
      end
    end

    context 'when no results found' do
      it 'returns no results found error' do
        get '/api/v2/search/restaurants', params: {q: 'NonExistent'}
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('No results found')
      end
    end
  end

  describe 'GET /api/v2/search/foods' do
    context 'when search query is present' do
      it 'returns search results for foods' do
        get '/api/v2/search/foods', params: {q: 'Test'}
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Search results')
        expect(json['results']).to_not be_empty
      end
    end

    context 'when search query is absent' do
      it 'returns an error' do
        get '/api/v2/search/foods'
        expect(response).to have_http_status(:bad_request)
        expect(json['error']).to eq('q is missing')
      end
    end

    context 'when no results found' do
      it 'returns no results found error' do
        get '/api/v2/search/foods', params: {q: 'NonExistent'}
        expect(response).to have_http_status(:not_found)
        expect(json['message']).to eq('No results found')
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
