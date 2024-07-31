module V2
  class HomeAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers HomesHelper
    helpers AuthHelper

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

      before { authenticate }
      before { initialize_cart }

      desc 'Add to Cart'
      params do
        requires :food_id, type: String, desc: 'Food item ID'
      end
      post "cart/add" do
        if @current_user
          add_to_cart
        else 
          error!({message: 'You need to login to access this feature'}, 401)
        end
      end 

      desc 'Remove from Cart'
      params do
        requires :food_id, type: String, desc: 'Food item ID'
      end
      post "cart/remove" do
        if @current_user
          remove_from_cart
        else 
          error!({message: 'You need to login to access this feature'}, 401)
        end
      end

      desc 'Display Cart Items'
      get 'cart' do
        if @current_user
          load_cart
          {message: 'Cart Items', food_items: @food_items, quantities: @cart}
        else
          error!({message: 'You need to login to access this feature'}, 401)
        end
      end

      desc 'Checkout Cart'
      params do
        requires :address, type: String, desc: 'Delivery address'
      end
      post '/cart/checkout' do
        load_cart
        checkout_cart
      end
    end
  end
end