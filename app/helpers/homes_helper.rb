module HomesHelper
  include RedisHelper

  def load_home_restaurants
    r_page = params[:r_page].present? ? params[:r_page].to_i : 1
    r_page_size = limit
    offset = (r_page - 1) * r_page_size

    cache_key = "index_restaurant_#{r_page}_size_#{r_page_size}"    

    begin
    @restaurants = get_cached_data(cache_key) do
      Restaurant.limit(r_page_size).offset(offset)
    end 
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error("Error while loading restaurants: #{e.message}")
      @restaurants = []
    end
  end

  def load_home_foods
    
    f_page = params[:f_page].present? ? params[:f_page].to_i : 1
    f_page_size = limit
    offset = (f_page - 1) * f_page_size
    
    # TODO
    if params[:filter].present?
      categories = JSON.parse(params[:filter])
      cache_key = "index_food_#{categories}"
      
      begin
        @foods = get_cached_data(cache_key) do
          Food.limit(f_page_size).offset(offset).where(category: categories)
        end
      rescue ActiveRecord::ActiveRecordError => e
          Rails.logger.error("Error while loading foods: #{e.message}")
          @foods = []
      end 

    else
      cache_key = "index_food_#{f_page}_size_#{f_page_size}"
      begin
        @foods = get_cached_data(cache_key) do
          Food.limit(f_page_size).offset(offset)
        end
      rescue ActiveRecord::ActiveRecordError => e
        Rails.logger.error("Error while loading foods: #{e.message}")
        @foods = []
      end 
    end

    # begin
    #   @foods = get_cached_data(cache_key) do
    #     Food.limit(f_page_size).offset(offset)
    #   end
    # rescue ActiveRecord::ActiveRecordError => e
    #   Rails.logger.error("Error while loading foods: #{e.message}")
    #   @foods = []
    # end 
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
    page = params[:page].present? ? params[:page].to_i : 1
    page_size = limit
    offset = (page - 1) * page_size

    @query = params[:q] 
      
    if @query.blank?
      error!({ message: 'Search query cannot be blank' }, 422)
    else
      restaurant_results = Restaurant.select(:name, :email, :description, :id, :image_url)
                                     .where("name ILIKE ?", "%#{@query}%")
                                     .limit(page_size)
                                     .offset(offset)

      if restaurant_results.blank? 
        error!({ message: 'No results found' }, 404)
      else
        { message: 'Search results', results: restaurant_results }
      end
    end
  end

  def search_all_foods
    page = params[:page].present? ? params[:page].to_i : 1
    page_size = limit
    offset = (page - 1) * page_size
    @query = params[:q]
      
    if @query.blank?
      error!({ message: 'Search query cannot be blank' }, 422)
    else
      food_results = Food.where("name ILIKE ?", "%#{@query}%")
                         .limit(page_size)
                         .offset(offset)

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
end
