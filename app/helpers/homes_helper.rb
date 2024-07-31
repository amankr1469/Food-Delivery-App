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
      restaurant_results = Restaurant.select(:name, :email, :description, :id).where("name ILIKE ?", "%#{@query}%")
      if restaurant_results.blank? 
        error!({ message: 'No results found' }, 404)
      else
        { message: 'Search results', results: restaurant_results }
      end
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

  private

  def limit 
    limit_value = params[:limit].present? ? params[:limit].to_i : 100
    [limit_value, 100].min
  end
  
end
