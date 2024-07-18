json.extract! food, :id, :name, :description, :price, :restaurant_id, :category, :raing, :image_url, :created_at, :updated_at
json.url food_url(food, format: :json)
