module FoodEntity
  class Index < Grape::Entity
    expose :id,
           :name, 
           :price
  end

  class Details < Grape::Entity
    expose :id, 
           :name, 
           :price,
           :description,
           :category

  end
end