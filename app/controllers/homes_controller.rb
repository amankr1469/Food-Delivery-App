class HomesController < ApplicationController
  before_action :authenticate_request, except: [:index, :search, :search_results, :view_all_restaurants, :view_all_foods, :restaurant]
  before_action :set_home_restaurants, :set_home_food
  before_action :initialize_cart, only: [:add_to_cart, :remove_from_cart, :cart]

  #Root URL
  def index
    @current_user
  end 

  def add_to_cart
    if @current_user

      food_id = params[:food_id]
      if food_id.blank?
        redirect_back(fallback_location: root_path, notice: "Invalid food item.")
        return
      end

      if @cart[food_id] 
        @cart[food_id]["quantity"] = (@cart[food_id]["quantity"] || 0) + 1
      else
     
      cart_item = { quantity: 1 }

      @cart[food_id] = cart_item
    end
      
      save_cart
      redirect_back(fallback_location: root_path, notice: "Item added to cart.")
    else 
      redirect_to users_login_path, notice: "You need to log in to add items to the cart."
    end
  end

  def remove_from_cart
    if @current_user
      food_id = params[:food_id]

      if food_id.blank?
        redirect_back(fallback_location: root_path, notice: "Invalid food item.")
        return
      end

        if @cart[food_id] && @cart[food_id]["quantity"] > 1
          @cart[food_id]["quantity"] = @cart[food_id]["quantity"] - 1

        else
          @cart.delete(food_id) 
        end

      save_cart
      redirect_back(fallback_location: root_path, notice: "Item removed from cart.")
    else 
    redirect_to users_login_path, notice: "You need to log in to remove items from the cart."
    end
  end

  def cart
    if @current_user
      load_cart
    else
      redirect_to users_login_path, notice: "You need to log in to view the cart."
    end
  end

  def checkout
    if @current_user
      load_cart
      if @cart.empty?
        redirect_to users_cart_path, notice: "Your cart is empty."
        return
      end

      address = params[:address]
      if address.blank?
        redirect_to users_cart_path, notice: "Address cannot be blank."
        return
      end

      total_amount = calculate_total_amount
      order = Order.new(
        user_id: @current_user.id,
        food_quantities: @cart,
        address: address,
        total_amount: total_amount
      )

      if order.save
        clear_cart
        redirect_to root_path, notice: "Order placed successfully."
      else
        redirect_to users_cart_path, notice: "Failed to place order."
      end
    else
      redirect_to users_login_path, notice: "You need to log in to place an order."
    end
  end

  def search 
  end

  def search_results
    
    @query = params[:q]
    if @query.blank?
      redirect_back(fallback_location: root_path, notice: 'Search query cannot be blank.')
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
    if params[:id].blank?
      redirect_back(fallback_location: root_path, notice: 'Invalid restaurant ID.')
      return
    end

    if params[:id]
    end

    @restaurant = Restaurant.find_by(id: params[:id])
    if @restaurant.nil?
      redirect_back(fallback_location: root_path, notice: 'Restaurant not found.')
      return
    end
    @food_items = @restaurant.foods
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
    if @current_user
      cart_data = $redis.get(@current_user.id)
      @cart = cart_data.present? ? JSON.parse(cart_data) : {}
    else
      @cart = {}
    end
  end

  def save_cart
    $redis.set(@current_user.id, @cart.to_json)
    $redis.expire(@current_user.id, 24.hours.to_i)
  end

  def clear_cart
    $redis.del(@current_user.id)
  end

  def load_cart
    initialize_cart
    food_ids = @cart.keys
    @food_items = Food.where(id: food_ids)
  end

  def calculate_total_amount
    total = 0
    @food_items.each do |food|
      quantity = @cart[food.id.to_s]["quantity"]
      total += food.price * quantity
    end
    total
  end
end
