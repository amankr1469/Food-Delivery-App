class FoodsController < ApplicationController
  include RedisHelper
  before_action :authenticate_request
  before_action :set_food, only: %i[ show edit update destroy ]

  def index
    
  end

  def show
  end

  def new
    @food = Food.new
  end

  def edit
  end

  def create
    @food = Food.new(food_params)
    begin
    @food.save!
      if @food.image.attached?
        @food.update(image_url: url_for(@food.image))
      end
      invalidate_cache("admin_#{@current_user.id}_page_*")
      invalidate_cache("index_food_*")
      redirect_to @food, notice: 'Food was successfully created.'
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity, notice: "Failed to create restaurant: #{e.message}"
    rescue => e
      render :new, status: :unprocessable_entity, alert: "Unexpected error: #{e.message}"
    end
  end

  def update
    begin
    @food.update!(food_params)
      if @food.image.attached?
        @food.update!(image_url: url_for(@food.image))
      end
      invalidate_cache("admin_#{@current_user.id}_page_*")
      invalidate_cache("index_food_*")
      redirect_to food_url(@food), notice: "Food was successfully updated."
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity, notice: "Failed to create restaurant: #{e.message}"
    rescue => e
      render :edit, status: :unprocessable_entity, alert: "Failed to update food: #{e.message}"
    end
  end

  def destroy
    @food.destroy!
    invalidate_cache("admin_#{@current_user.id}_page_*")
    invalidate_cache("index_food_*")
    respond_to do |format|
      format.html { redirect_to restaurants_url, notice: "Food was successfully destroyed." }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to foods_url, notice: "Failed to destroy food: #{e.message}"
  end

  private
    def set_food
      @food = Food.find(params[:id])
    end

    def food_params
      params.require(:food).permit(:name, :description, :price, :category, :image, :restaurant_id)
    end
end
