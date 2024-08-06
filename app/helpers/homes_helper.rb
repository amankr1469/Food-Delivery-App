module HomesHelper
  include RedisHelper

  def load_home_restaurants
    page = params[:page].present? ? params[:page].to_i : 1
    page_size = limit
    offset = (page - 1) * page_size

    cache_key = "index_restaurant_#{page}_size_#{page_size}"

    begin
    @restaurants = get_cached_data(cache_key) do
      Restaurant.limit(page_size).offset(offset)
    end 
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error("Error while loading restaurants: #{e.message}")
      @restaurants = []
    end
  end

  def load_home_foods
    page = params[:page].present? ? params[:page].to_i : 1
    page_size = limit
    offset = (page - 1) * page_size

    cache_key = "index_food_#{page}_size_#{page_size}"

    begin
    @foods = get_cached_data(cache_key) do
      Food.limit(page_size).offset(offset)
    end
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error("Error while loading foods: #{e.message}")
      @foods = []
    end 
  end

  def perform_search
    @query = params[:q]
      
    if @query.blank?
      error!({ message: 'Search query cannot be blank' }, 422)
    else
      results = {}
      results[:restaurants] = Restaurant.where("name ILIKE ?", "%#{@query}%").limit(5)
      results[:foods] = Food.where("name ILIKE ?", "%#{@query}%").limit(5)
      { message: 'Search results', results: results }
    end
  end

  def search_all_restaurants
    @query = params[:q] 
      
    if @query.blank?
      error!({ message: 'Search query cannot be blank' }, 422)
    else
      restaurant_results = Restaurant.select(:name, :email, :description, :id).where("name ILIKE ?", "%#{@query}%")
      if restaurant_results.blank? 
        error!({ message: 'No results found' }, 404)
      else
        { message: 'Search results', results: restaurant_results }
      end
    end
  end

  def search_all_foods
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

  private

  def limit 
    limit_value = params[:page_size].present? ? params[:page_size].to_i : 100
    [limit_value, 100].min
  end

  def load_redis_data()
    
  end
end
