module V2
  class CartAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers CartHelper
    helpers AuthHelper

    before { authenticate }
    before { initialize_cart }

    resources '/cart' do
      desc 'Add to Cart'
      params do
        requires :food_id, type: String, desc: 'Food item ID'
      end
      post "/add" do
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
      post "/remove" do
        if @current_user
          remove_from_cart
        else 
          error!({message: 'You need to login to access this feature'}, 401)
        end
      end
  
      desc 'Display Cart Items'
      get '/' do
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
      post '/checkout' do
        load_cart
        checkout_cart
      end
    end
  end
end