module RestaurantEntity
  class Index < Grape::Entity
    expose :id, 
           :name, 
           :description,
           :image_url
  end

  class Details < Grape::Entity
    expose :id,
           :name, 
           :location, 
           :pincode, 
           :contact_number, 
           :email, 
           :description, 
           :opening_hours, 
           :delivery_radius,
           :image_url
  end
end