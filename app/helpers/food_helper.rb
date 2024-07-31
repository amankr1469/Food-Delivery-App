module FoodHelper
  def get_food_details
    begin
      food = Food.find(params[:id])
      { message: 'Food item details', food: food }
    rescue ActiveRecord::RecordNotFound
      error!({ message: 'Food item not found' }, 404)
    rescue => e
      error!({ message: 'Failed to retrieve food item', error: e.message }, 500)
    end
  end

  def update_food_details
    begin
      food = Food.find(params[:id])
      
      update_params = {}
      update_params[:name] = params[:name] if params[:name].present?
      update_params[:description] = params[:description] if params[:description].present?
      update_params[:price] = params[:price] if params[:price].present?
      update_params[:category] = params[:category] if params[:category].present?
      update_params[:image] = params[:image] if params[:image].present?
  
      if update_params[:name].nil? && params[:name].present?
        error!({ message: 'Name cannot be blank' }, 422)
      end
  
      if update_params[:price].nil? && params[:price].present?
        error!({ message: 'Price cannot be blank' }, 422)
      end
  
      food.update!(update_params)
      { message: 'Food item details updated successfully', food: food }
    rescue ActiveRecord::RecordNotFound
      error!({ message: 'Food item not found' }, 404)
    rescue ActiveRecord::RecordInvalid => e
      error!({ message: 'Failed to update food item', error: e.message }, 422)
    rescue => e
      error!({ message: 'Internal server error', error: e.message }, 500)
    end
  end

  def delete_the_food
    begin
      food = Food.find(params[:id])
      food.destroy!
      { message: 'Food item successfully deleted' }
    rescue ActiveRecord::RecordNotFound
      error!({ message: 'Food item not found' }, 404)
    rescue => e
      error!({ message: 'Failed to delete food item', error: e.message }, 500)
    end
  end

  def create_food_item
    begin
      food_params = {
        name: params[:name],
        description: params[:description],
        price: params[:price],
        category: params[:category],
        restaurant_id: params[:restaurant_id]
      }
  
      food = Food.new(food_params)
  
      if food.save!
        { message: 'Food item created successfully', food: food }
      else
        error!({ message: 'Failed to create food item' }, 422)
      end
    rescue ActiveRecord::RecordInvalid => e
      error!({ message: e.message }, 422)
    rescue => e
      error!({ message: 'Internal server error', error: e.message }, 500)
    end
  end
end
