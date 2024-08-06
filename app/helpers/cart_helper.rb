module CartHelper
  def add_to_cart
    food_id = params[:food_id]
    if food_id.blank?
      error!({message: 'ID invalid'}, 401)
    end

    if @cart[food_id] 
      @cart[food_id]["quantity"] = (@cart[food_id]["quantity"] || 0) + 1
    else
   
    cart_item = { quantity: 1 }

    @cart[food_id] = cart_item
    end
    save_cart
    {message: 'Item added to cart'}
  end

def remove_from_cart
    food_id = params[:food_id]

    if food_id.blank?
      error!({message: 'ID invalid'}, 401)
    end

    if @cart[food_id] && @cart[food_id]["quantity"] > 1
       @cart[food_id]["quantity"] = @cart[food_id]["quantity"] - 1

    else
      @cart.delete(food_id) 
    end

    save_cart
    {message: "Item removed from cart."}
end

def checkout_cart
  if @cart.empty?
    error!({ message: 'Cart is empty' }, 422)
  end

  address = params[:address]
  if address.blank?
    error!({ message: "Address can't be blank" }, 422)
  end

  total_amount = calculate_total_amount
  order = Order.new(
    user_id: @current_user.id,
    food_quantities: @cart,
    address: address,
    total_amount: total_amount
  )

  begin
    order.save!
    clear_cart
    CheckoutMailerJob.perform_async(@current_user.id)
    { message: 'Order placed successfully' }
  rescue ActiveRecord::RecordInvalid => e
    error!({ message: "Failed to place order: #{e.message}" }, 422)
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
  food_ids = @cart.keys.map(&:to_i)
  @food_items = Food.where(id: food_ids)

  found_food_ids = @food_items.pluck(:id)
  missing_food_ids = food_ids - found_food_ids

  result = {
    message: 'Cart Items',
    food_items: FoodEntity::Details.represent(@food_items) ,
    quantities: @cart,
    total_cost: calculate_total_amount
  }
  
  if missing_food_ids.any?
    missing_messages = missing_food_ids.map do |missing_id|
      "Food item with ID #{missing_id} is no longer available. Restaurant is no longer serving this dish."
    end
    result[:missing_items] = missing_messages
  end

  result
end

def calculate_total_amount
  total = 0
  @food_items.each do |food|
    quantity = @cart[food.id.to_s]["quantity"]
    total += food.price * quantity
  end
  total
end
end