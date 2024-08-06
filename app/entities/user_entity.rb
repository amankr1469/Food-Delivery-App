module UserEntity
  class Details < Grape::Entity
    expose :name, :email, :contact_number
  end 
end