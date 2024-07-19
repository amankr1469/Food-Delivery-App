class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[ show edit update destroy ]

  #This will load all the restautants of a particular admin
  def index
    @restaurants = Restaurant.all
  end

  #This will show food items in that particular restaurants
  def show
    @foods = Food.all
  end

  #This will search name of particular restaurant created by that user
  def search
    
  end

  # Result of search
  def results
    @query = params[:q]
    @results = perform_search(@query)
  end

  # Add new restaurant
  def new
    @restaurant = Restaurant.new
  end


  # View and end Restaurant Details
  def edit
  end


  def create
    @restaurant = Restaurant.new(restaurant_params)

    respond_to do |format|
      if @restaurant.save
        format.html { redirect_to restaurant_url(@restaurant), notice: "Restaurant was successfully created." }
        # format.json { render :show, status: :created, location: @restaurant }
      else
        format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @restaurant.update(restaurant_params)
        format.html { redirect_to restaurant_url(@restaurant), notice: "Restaurant was successfully updated." }
        format.json { render :show, status: :ok, location: @restaurant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @restaurant.destroy

    respond_to do |format|
      format.html { redirect_to restaurants_url, notice: "Restaurant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_restaurant
      @restaurant = Restaurant.find(params[:id])
    end

    def restaurant_params
      params.require(:restaurant).permit(:user_id, :location, :pincode, :contact_number, :email, :description, :opening_hours, :delivery_radius, :logo_url, :menu_url)
    end

    def perform_search
      results = []
      results += Restaurant.where("name LIKE ?", "%#{query}%", "%#{query}%")
      results += Food.where("name LIKE ?", "%#{query}%")
      results
    end
end
