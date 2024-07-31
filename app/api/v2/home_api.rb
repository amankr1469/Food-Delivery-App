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
        @query = params[:q]
      
        if @query.blank?
          error!({ message: 'Search query cannot be blank' }, 422)
        else
          food_results = Food.where("name ILIKE ?", "%#{@query}%")
          if food_results.blank? 
            error!({ message: 'No results found' }, 404)
          else
            { message: 'Search results', results: food_results }
          end
        end
      end

      before { authenticate }
      before { initialize_cart }

      desc 'Add to Cart'
      params do
        requires :food_id, type: String, desc: 'Food item ID'
      end
      post "cart/add" do
        if @current_user
          food_id = params[:food_id]
          if food_id.blank?
            error!({message: 'ID invalid'}, 401)
          end
    
          if @cart[food_id] 
            @cart[food_id]["quantity"] = (@cart[food_id]["quantity"] || 0) + 1
          else
         
          cart_item = { quantity: 1 }
    
          @cart[food_id] = cart_item
        end
          save_cart
          {message: 'Item added to cart'}
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
          food_id = params[:food_id]
    
          if food_id.blank?
            error!({message: 'ID invalid'}, 401)
          end
    
          if @cart[food_id] && @cart[food_id]["quantity"] > 1
             @cart[food_id]["quantity"] = @cart[food_id]["quantity"] - 1
    
          else
            @cart.delete(food_id) 
          end
    
          save_cart
          {message: "Item removed from cart."}
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
      
        if @cart.empty?
          error!({ message: 'Cart is empty' }, 422)
        end
      
        address = params[:address]
        if address.blank?
          error!({ message: "Address can't be blank" }, 422)
        end
      
        total_amount = calculate_total_amount
        order = Order.new(
          user_id: @current_user.id,
          food_quantities: @cart,
          address: address,
          total_amount: total_amount
        )
      
        begin
          order.save!
          clear_cart
          { message: 'Order placed successfully' }
        rescue ActiveRecord::RecordInvalid => e
          error!({ message: "Failed to place order: #{e.message}" }, 422)
        end
      end
    end
  end
end