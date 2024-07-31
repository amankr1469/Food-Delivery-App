module V2
  class RestaurantAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers AuthHelper
    
    before { authenticate }
    before { admin_only }

    resources '/admin' do
      desc 'Admin Dashboard Page'    
      get '/restaurants' do
        if @current_user
          begin
            restaurants = Restaurant.where(user_id: @current_user.id)
            if restaurants.any?
              { message: 'All the restaurants of logged in admin', restaurants: restaurants }
            else
              error!({ message: 'No restaurants found for the current admin' }, 404)
            end
          rescue StandardError => e
            error!({ message: 'Failed to retrieve restaurants', error: e.message }, 500)
          end
        else
          error!({ message: 'You need to login to access this feature' }, 401)
        end
      end

      desc 'Show particular Restaurant Details'
      params do
        requires :id, type: String, desc: 'Restaurants ID'
      end
      get '/restaurant' do
        if @current_user
          begin
            restaurant = Restaurant.find(params[:id])
            if restaurant.present?
              { message: 'Restaurants details', restaurant: restaurant }
            else
              error!({ message: 'No restaurants found for the current ID' }, 404)
            end
          rescue StandardError => e
            error!({ message: 'Failed to retrieve restaurant', error: e.message }, 500)
          end
        else
          error!({ message: 'You need to login to access this feature' }, 401)
        end
      end

      desc 'Foods items of particular restaurant' 
      params do
        requires :id, type: String, desc: 'Food ID'
      end
      get '/restaurant/foods' do
        if @current_user
          begin
            foods = Food.where("restaurant_id = ?", params[:id])
            if food.any?
              { message: 'All the foods of this restaurnat', foods: foods }
            else
              error!({ message: 'No food found for the current ID' }, 404)
            end
          rescue StandardError => e
            error!({ message: 'Failed to retrieve food', error: e.message }, 500)
          end
        else
          error!({ message: 'You need to login to access this feature' }, 401)
        end
      end

      desc 'Add new restaurant'
      params 
      post '/restaurant/new' do
        
      end

      desc 'Update restaurant details'

      desc 'Delete a restaurant'


    end
  end
end