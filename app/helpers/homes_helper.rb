module HomesHelper

  def load_home_restaurants
    @restaurants = Restaurant.select(:name, :description, :id).limit(limit).offset(params[:offset])
  end

  def load_home_foods
    @foods = Food.select(:name, :price, :id).limit(limit).offset(params[:offset])
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
    limit_value = params[:limit].present? ? params[:limit].to_i : 100
    [limit_value, 100].min
  end
  
end
