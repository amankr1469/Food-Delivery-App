class HomesController < ApplicationController
  before_action :authenticate_request, except: [:index, :search, :search_results, :view_all_restaurants, :view_all_foods, :restaurant]
  before_action :set_home_restaurants, :set_home_food
  before_action :initialize_cart, only: [:add_to_cart, :remove_from_cart, :cart]

  #Root URL
  def index
    
  end

  def add_to_cart
    if @current_user
          
      food_id = params[:food_id]

      if @cart[food_id] 
        @cart[food_id]["quantity"] = (@cart[food_id]["quantity"] || 0) + 1
      else
     
      cart_item = {
        quantity: 1
      }
      @cart[food_id] = cart_item
    end
      
      save_cart
      redirect_back(fallback_location: root_path, notice: "Item added to cart.")
    else 
      redirect_to users_login_path
    end
  end

  def remove_from_cart
    if @current_user
      food_id = params[:food_id]
      if @cart[food_id] && @cart[food_id]["quantity"] > 1
        @cart[food_id]["quantity"] = @cart[food_id]["quantity"] - 1
      else
        food_id = params[:food_id]
        @cart.delete(food_id) 
      end
      save_cart
      redirect_back(fallback_location: root_path, notice: "Item removed from cart.")
  else 
    redirect_to users_login_path
  end
  end

  def cart
    load_cart
  end

  def checkout
    if @current_user
      load_cart
      order = Order.new(
        user_id: @current_user.id,
        food_quantities: @cart,
        address: params[:address],
        total_amount: params[:total_amount]
      )
      
      if order.save
        clear_cart
        redirect_to root_path, notice: "Order placed successfully."
      else
        redirect_to cart_path, alert: "Failed to place order."
      end
    else
      redirect_to users_login_path
    end
  end

  def search 
  end

  def search_results
    @query = params[:q]
    if @query.blank?
      flash[:alert] = 'Search query cannot be blank.'
      redirect_to request.referer
    else
    @results = perform_search
    end
  end

  def view_all_restaurants
    @query = params[:q]
    @restaurant_results = Restaurant.where("name ILIKE ?", "%#{@query}%")
  end

  def view_all_foods
    @query = params[:q]
    @food_results = Food.where("name ILIKE ?", "%#{@query}%")
  end

  def restaurant
    @restaurant = Restaurant.find(params[:id])
    @food_items = @restaurant.foods
    # @food_items = Food.where("restaurant_id = ?", params[:id])
  end

  private

  def set_home_restaurants
    @restaurants = Restaurant.all.limit(6)
  end

  def set_home_food
    @foods = Food.all.limit(6)
  end

  def perform_search
    results = {}
    results[:restaurants] = Restaurant.where("name ILIKE ?", "%#{@query}%").limit(5)
    results[:foods] = Food.where("name ILIKE ?", "%#{@query}%").limit(5)
    results
  end

  def initialize_cart
    cart_data = $redis.get(@current_user.id)
    @cart = cart_data.present? ? JSON.parse(cart_data) : {}
  end

  def save_cart
    $redis.set(@current_user.id, @cart.to_json)
  end

  def clear_cart
    $redis.del(@current_user.id)
  end

  def load_cart
    initialize_cart
    food_ids = @cart.keys
    @food_items = Food.where(id: food_ids)
  end
end
