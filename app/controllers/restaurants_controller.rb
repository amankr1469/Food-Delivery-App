class RestaurantsController < ApplicationController
  include RedisHelper
  before_action :authenticate_request
  before_action :set_user
  before_action :set_restaurant, only: %i[ show edit update destroy ]
  before_action :admin_only
  before_action :set_pagination_params, only: [:index, :show, :results]

  #This will load all the restautants of a particular admin
  def index
    user_id = @current_user.id
    
    uri = URI("http://localhost:3000/api/v2/admin/restaurants?page=#{@page}&page_size=#{@page_size}&user_id=#{user_id}")
    
    begin
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
      
      if parsed_response["restaurants"].present?
        @restaurants = parsed_response["restaurants"]
      else
        flash[:notice] = parsed_response["message"] || "No restaurant found for the current ID."
        @restaurants = []
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      flash[:notice] = "Failed to retrieve data due to a timeout. Please try again later."
      @restaurants = []
    rescue => e
      flash[:notice] = "Failed to retrieve data. Error: #{e.message}"
      @restaurants = []
    end
  end

  #This will show food items in that particular restaurants
  def show
    r_id = params[:id].to_i
    
    uri = URI("http://localhost:3000/api/v2/admin/foods/restaurant?page=#{@page}&page_size=#{@page_size}&id=#{r_id}")
    
    begin
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
      
      if parsed_response["foods"].present?
        @foods = parsed_response["foods"]
      else
        flash[:notice] = parsed_response["message"] || "No food found for the current ID."
        @foods = []
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      flash[:notice] = "Failed to retrieve food due to a timeout. Please try again later."
      @foods = []
    rescue => e
      flash[:notice] = "Failed to retrieve food. Error: #{e.message}"
      @foods = []
    end
  end

  # Result of search
  def results
    @query = params[:q]
    @restaurants = perform_search

    render :results
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
  
    begin
      @restaurant.save!
      if @restaurant.image.attached?
        @restaurant.update!(image_url: url_for(@restaurant.image))
      end
      invalidate_cache("admin_#{@current_user.id}_page_*")
      invalidate_cache("index_restaurant_*")
      redirect_to @restaurant, notice: 'Restaurant was successfully created.'
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity, notice: "Failed to create restaurant: #{e.message}"
    end
  end
  

  def update
    respond_to do |format|
      begin
        @restaurant.update!(restaurant_params)
        if @restaurant.image.attached?
          @restaurant.update!(image_url: url_for(@restaurant.image))
        end
        invalidate_cache("admin_#{@current_user.id}_page_*")
        invalidate_cache("index_restaurant_*")
        format.html { redirect_to restaurant_url(@restaurant), notice: "Restaurant was successfully updated." }
        format.json { render :show, status: :ok, location: @restaurant }
      rescue ActiveRecord::RecordInvalid => e
        format.html { render :edit, status: :unprocessable_entity, notice: "Failed to update restaurant: #{e.message}" }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @restaurant.destroy!
    invalidate_cache("admin_#{@current_user.id}_page_*")
    invalidate_cache("index_restaurant_*")
    respond_to do |format|
      format.html { redirect_to restaurants_url, notice: "Restaurant was successfully destroyed." }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to restaurants_url, notice: "Failed to destroy restaurant: #{e.message}"
  end

  def report
    uri = URI("http://localhost:3000/api/v2/admin/export_csv?user_id=#{@current_user.id}")

    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    
    redirect_to restaurants_url , notice: parsed_response["message"]
  end

  def download
      user_id = @current_user.id
      file_path = Rails.root.join('public', "restaurants #{user_id}-#{Date.current}.csv")
      if File.exist?(file_path)
        send_file(file_path, type: 'text/csv', filename: "report.csv", disposition: 'attachment')
        # File.delete(file_path) if File.exist?(file_path)
      else
        redirect_to restaurants_url, notice: 'Report file not found. Please generate the report first.'
      end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_url, notice: "Restaurant not found."
  end

    def set_user
      @user = @current_user
    end

    def restaurant_params
      params.require(:restaurant).permit(:name,:location, :pincode, :contact_number, :email, :description, :opening_hours, :delivery_radius, :image)
    end

    def perform_search
      page = params[:page].present? ? params[:page].to_i : 1
      page_size = @page_size
      offset = (page - 1) * page_size
      results = []
      results += Restaurant.where("user_id = ? AND name ILIKE ?", @current_user.id, "%#{@query}%").limit(page_size).offset(offset)
      results
    end

    def set_pagination_params
      @page = params[:page].to_i if params[:page].present?
      @page ||= 1
      @page_size = params[:page_size].to_i if params[:page_size].present?
      @page_size ||= 10
    end

end
