module V2
  class HomeAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers HomesHelper

    resources "/" do
      desc 'Home Page'
      get "/index" do
        load_home_restaurants
        load_home_foods
        {
          message: 'Home Page with Restaurants and Foods',
          restaurant: @restaurants, 
          food: @foods
        }
      end 

      desc 'Search Query'
      params do
        requires :q, type: String, desc: 'Search query'
      end
      get "/search" do
        perform_search
      end

      desc 'View all restaurants with query keyword'
      params do
        requires :q, type: String, desc: 'Search query'
      end
      get "/search/restaurants" do
        search_all_restaurants
      end

      desc 'View all food items with query keyword'
      params do
        requires :q, type: String, desc: 'Search query'
      end
      get "/search/foods" do
        search_all_foods
      end

    end
  end
end