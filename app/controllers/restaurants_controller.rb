class RestaurantsController < ApplicationController
  before_action :authenticate_request
  before_action :set_user
  before_action :set_restaurant, only: %i[ show edit update destroy ]
  before_action :admin_only
  before_action :correct_user, only: %i[ show edit update destroy ]

  #This will load all the restautants of a particular admin
  def index
    @restaurants = Restaurant.where("user_id = ?", @user.id)
  end

  #This will show food items in that particular restaurants
  def show
    @foods = Food.where("restaurant_id = ?", @restaurant.id)
  end

  #This will search name of particular restaurant created by that user

  # Result of search
  def results
    @query = params[:q]
    @restaurants = perform_search
    render :index
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
    @restaurant.user = @current_user

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

    def set_user
      @user = @current_user
    end

    def restaurant_params
      params.require(:restaurant).permit(:name,:location, :pincode, :contact_number, :email, :description, :opening_hours, :delivery_radius, :image)
    end

    def perform_search
      results = []
      results += Restaurant.where("user_id = ? AND name LIKE ?", @current_user.id, "%#{@query}%")
      results
    end

    def correct_user
      unless @restaurant.user_id == @current_user.id
        flash[:alert] = 'Not authorized to access this restaurant.'
        redirect_to restaurants_path
      end
    end
end
