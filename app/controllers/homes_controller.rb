class HomesController < ApplicationController
  # before_action :authenticate_request
  before_action :set_home_restaurants, :set_home_food

  #Root URL
  def index
    
  end

  def add_to_cart
    
  end

  def remove_from_cart
    
  end

  def search 
  end

  def search_results
    @query = params[:q]
    @results = perform_search(@query)
  end

  def view_all_restaurants
    
  end

  def view_all_food
    
  end

  def restaurant
    
  end

  private

  def set_home_restaurants
    @restaurants = Restaurant.all
  end

  def set_home_food
    @foods = Food.all
  end

  def perform_search(query)

  results = {
    restaurants: [],
    foods: []
  }

  results[:restaurants] += Restaurant.where("name ILIKE ?", "%#{params[:query]}%").limit(5)
  results[:foods] += Food.where("name ILIKE ?", "%#{params[:query]}%").limit(5)

  results
  end

end
