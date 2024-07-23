json.extract! restaurant, :id, :user_id, :location, :pincode, :contact_number, :email, :description, :opening_hours, :delivery_radius, :created_at, :updated_at
json.url restaurant_url(restaurant, format: :json)
