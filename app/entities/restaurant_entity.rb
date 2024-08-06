module RestaurantEntity
  class Index < Grape::Entity
    expose :id, 
           :name, 
           :description
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
           :delivery_radius
  end
end