module RestaurantHelper
  include RedisHelper

  def get_admin_restaurants
    page = params[:page].present? ? params[:page].to_i : 1
    page_size = limit
    offset = (page - 1) * page_size

    cache_key = "admin_#{@current_user.id}_page_#{page}_size_#{page_size}"
     
    restaurants = get_cached_data(cache_key) do
      Restaurant.where(user_id: @current_user.id).limit(page_size).offset(offset)
    end

    if restaurants.any? 
      {
        message: 'All the restaurants of logged in admin',
        restaurants: RestaurantEntity::Details.represent(restaurants),
        current_page: page,
        page_size: page_size,
      }
    else
      { message: 'No restaurants found for the current admin', restaurants: [] }
    end
    rescue => e
      error!({ message: 'Failed to retrieve restaurants', error: e.message }, 500)
    end

  def get_restaurant_details
    begin
      restaurant = Restaurant.find(params[:id])
      { message: 'Restaurant details', restaurant: RestaurantEntity::Details.represent(restaurant) }
    rescue ActiveRecord::RecordNotFound
      error!({ message: 'Restaurant not found for the given ID' }, 404)
    rescue => e
      error!({ message: 'Failed to retrieve restaurant', error: e.message }, 500)
    end
  end
  

  def get_restaurant_foods
    foods = Food.where("restaurant_id = ?", params[:id]).limit(limit).offset(params[:offset])
    if foods.any?
      { message: 'All the foods of this restaurnat', foods: foods }
    else
      { message: 'No food found for the current ID', foods: [] }
    end
    rescue => e
      error!({ message: 'Failed to retrieve food', error: e.message }, 500)
  end

  def create_new_restaurant(current_user)
      restaurant_params = {
        name: params[:name],
        location: params[:location],
        pincode: params[:pincode],
        contact_number: params[:contact_number],
        email: params[:email],
        description: params[:description],
        opening_hours: params[:opening_hours],
        delivery_radius: params[:delivery_radius],
      }

      restaurant = Restaurant.new(restaurant_params)
      restaurant.user = current_user
      restaurant.save!

      { message: 'Restaurant created successfully', restaurant: restaurant }
      rescue ActiveRecord::RecordInvalid => e
        error!({ message: e.message }, 422)
      rescue => e
        error!({ message: 'Internal server error' }, 500)
  end

  def update_restaurant_details
    begin
      restaurant = Restaurant.find(params[:id])
      #TODO
      if params[:name].present? && params[:name].blank?
        error!({ message: 'Name cannot be blank' }, 422)
      end
  
      if params[:email].present? && params[:email].blank?
        error!({ message: 'Email cannot be blank' }, 422)
      end

      update_params = {}
      update_params[:name] = params[:name] if params[:name].present?
      update_params[:location] = params[:location] if params[:location].present?
      update_params[:pincode] = params[:pincode] if params[:pincode].present?
      update_params[:contact_number] = params[:contact_number] if params[:contact_number].present?
      update_params[:email] = params[:email] if params[:email].present?
      update_params[:description] = params[:description] if params[:description].present?
      update_params[:opening_hours] = params[:opening_hours] if params[:opening_hours].present?
      update_params[:delivery_radius] = params[:delivery_radius] if params[:delivery_radius].present?

      restaurant.update!(update_params)
      { message: 'Restaurant details updated successfully', restaurant: restaurant }
    rescue ActiveRecord::RecordNotFound
      error!({ message: 'Restaurant not found' }, 404)
    rescue ActiveRecord::RecordInvalid => e
      error!({ message: 'Failed to update restaurant', error: e.message }, 422)
    rescue => e
      error!({ message: 'Internal server error', error: e.message }, 500)
    end
  end

  def delete_restaurant
    begin
      restaurant = Restaurant.find(params[:id])
      restaurant.destroy!
      { message: 'Restaurant successfully deleted' }
    rescue ActiveRecord::RecordNotFound
      error!({ message: 'Restaurant not found' }, 404)
    rescue => e
      error!({ message: 'Failed to delete restaurant', error: e.message }, 500)
    end
  end

  private
  def limit 
    limit_value = params[:page_size].present? ? params[:page_size].to_i : 100
    [limit_value, 100].min
  end
  
end
