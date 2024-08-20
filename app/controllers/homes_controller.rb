class HomesController < ApplicationController
  require 'net/http'
  before_action :authenticate_request, except: [:index, :search, :search_results, :view_all_restaurants, :view_all_foods, :restaurant]
  before_action :initialize_cart, only: [:add_to_cart, :remove_from_cart, :cart]
  before_action :set_pagination_params, only: [:view_all_restaurants, :view_all_foods, :restaurant]
  def index
    @restaurant_page = params[:r_page].to_i if params[:r_page].present?
    @restaurant_page ||= 1
  
    @food_page = params[:f_page].to_i if params[:f_page].present?
    @food_page ||= 1
  
    @page_size = params[:page_size].to_i if params[:page_size].present?
    @page_size ||= 10
  
    uri = URI("http://localhost:3000/api/v2/index?r_page=#{@restaurant_page}&f_page=#{@food_page}&page_size=#{@page_size}&filter=#{params[:categories]}")
  
    begin
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
  
      @restaurants = parsed_response["restaurant"] || []
      @foods = parsed_response["food"] || []
  
      if @restaurants.empty? && @foods.empty?
        flash[:notice] = parsed_response["message"] || "No restaurants or food items found for the given criteria."
      elsif @restaurants.empty?
        flash[:notice] = "No restaurants found, but here are some food items."
      elsif @foods.empty?
        flash[:notice] = "No food items found, but here are some restaurants."
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      flash[:alert] = "Failed to retrieve data due to a timeout. Please try again later."
      @restaurants = []
      @foods = []
    rescue => e
      flash[:alert] = "An unexpected error occurred: #{e.message}"
      @restaurants = []
      @foods = []
    end
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
      FoodCartMailerJob.perform_in(6.hours, @current_user.id)
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
    
    redirect_to users_login_path, flash[notice]= "You need to log in to remove items from the cart."
    end
  end

  def cart
    if @current_user
      load_cart
    else
      redirect_to users_login_path
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
  
      begin
        if order.save!
          clear_cart
          CheckoutMailerJob.perform_async(@current_user.id)
          redirect_to root_path, notice: "Order placed successfully."
        end
      rescue ActiveRecord::RecordInvalid => e
        redirect_to users_cart_path, notice: "Order placement failed: #{e.message}"
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
  
    uri = URI("http://localhost:3000/api/v2/search/restaurants?q=#{@query}&page=#{@page}&page_size=#{@page_size}")
  
    begin
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
  
      @restaurant_results = parsed_response["results"] || []
  
      if @restaurant_results.empty?
        flash[:notice] = parsed_response["message"] || "No restaurants found for the given query."
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      flash[:notice] = "Failed to retrieve data due to a timeout. Please try again later."
      @restaurant_results = []
    rescue => e
      flash[:notice] = "An unexpected error occurred: #{e.message}"
      @restaurant_results = []
    end
  end
  

  def view_all_foods
    @query = params[:q]
  
    uri = URI("http://localhost:3000/api/v2/search/foods?q=#{@query}&page=#{@page}&page_size=#{@page_size}")
  
    begin
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
  
      @food_results = parsed_response["results"] || []
  
      if @food_results.empty?
        flash[:notice] = parsed_response["message"] || "No food items found for the given query."
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      flash[:notice] = "Failed to retrieve data due to a timeout. Please try again later."
      @food_results = []
    rescue StandardError => e
      flash[:notice] = "An unexpected error occurred: #{e.message}"
      @food_results = []
    end
  end
  

  def restaurant
    offset = (@page - 1) * @page_size
  
    if params[:id].blank?
      redirect_back(fallback_location: root_path, notice: 'Invalid restaurant ID.')
      return
    end
  
    begin
      @restaurant = Restaurant.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_back(fallback_location: root_path, notice: 'Restaurant not found.')
      return
    end
  
    @food_items = @restaurant.foods.limit(@page_size).offset(offset)
  end
  

  def order_history
    if @current_user
      begin
        start_date = 7.days.ago.beginning_of_day
        @orders = Order.where(user_id: @current_user.id, created_at: start_date..Time.current)
        
        food_ids = @orders.map { |order| order.food_quantities.keys }.flatten
        @food_items = Food.where(id: food_ids).pluck(:id, :name).to_h
  
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Could not find your order history. Please try again later."
        @orders = []
      rescue => e
        flash[:notice] = "An error occurred while fetching your order history: #{e.message}"
        @orders = []
      end
    else
      redirect_to users_login_path, notice: "You need to log in to view your order history."
    end
  end
  
  
  private

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
    food_ids = @cart.keys.map(&:to_i)
    @food_items = Food.where(id: food_ids)

    found_food_ids = @food_items.pluck(:id)
    missing_food_ids = food_ids - found_food_ids
    
    if missing_food_ids.any?
      missing_messages = missing_food_ids.map do |missing_id|
        "Food item with ID #{missing_id} is no longer available. Restaurant is no longer serving this dish."
      end
      flash[:notice] = missing_messages
    end
  end

  def calculate_total_amount
    total = 0
    @food_items.each do |food|
      quantity = @cart[food.id.to_s]["quantity"]
      total += food.price * quantity
    end
    total
  end

  def set_pagination_params
    @page = params[:page].to_i if params[:page].present?
    @page ||= 1
    @page_size = params[:page_size].to_i if params[:page_size].present?
    @page_size ||= 10
  end
end
