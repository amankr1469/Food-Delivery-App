module MyGrapeAPI
  class Base < Grape::API
    format :json

    get :ping do
      { message: 'pong' }
    end

    mount V2::AuthAPI
    mount V2::HomeAPI
    mount V2::RestaurantAPI
    mount V2::FoodAPI
    mount V2::UserAPI
    
  end
end
