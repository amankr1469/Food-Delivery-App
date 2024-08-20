module FoodEntity
  class Index < Grape::Entity
    expose :id,
           :name, 
           :price,
           :category,
           :image_url
  end

  class Details < Grape::Entity
    expose :id, 
           :name, 
           :price,
           :description,
           :category,
           :image_url
  end
end