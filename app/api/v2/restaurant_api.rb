module V2
  class RestaurantAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers AuthHelper
    helpers RestaurantHelper
    
    before { authenticate }
    before { admin_only }

    resources '/admin' do
      desc 'Admin Dashboard Page'    
      get '/restaurants' do
        get_admin_restaurants
      end

      desc 'Show particular Restaurant Details'
      params do
        requires :id, type: String, desc: 'Restaurants ID'
      end
      get '/restaurant' do          
        get_restaurant_details
      end

      desc 'Foods items of particular restaurant' 
      params do
        requires :id, type: String, desc: 'Restaurant ID'
      end
      get '/foods/restaurant' do
        get_restaurant_foods
      end

      desc 'Add new restaurant'
      params do
        requires :name, type: String, desc: 'Restaurant name'
        requires :location, type: String, desc: 'Restaurant location'
        requires :pincode, type: Integer, desc: 'Restaurant pincode'
        requires :contact_number, type: String, desc: 'Restaurant contact number'
        requires :email, type: String, desc: 'Restaurant email'
        requires :description, type: String, desc: 'Restaurant description'
        requires :opening_hours, type: String, desc: 'Restaurant opening hours'
        requires :delivery_radius, type: Integer, desc: 'Restaurant delivery radius'
      end
      post '/restaurant/new' do
        create_new_restaurant(@current_user)
      end

      desc 'Update restaurant details'
      params do
        requires :id, type: String, desc: 'Restaurant ID'
        optional :name, type: String, desc: 'Restaurant name'
        optional :location, type: String, desc: 'Restaurant location'
        optional :pincode, type: Integer, desc: 'Restaurant pincode'
        optional :contact_number, type: String, desc: 'Restaurant contact number'
        optional :email, type: String, desc: 'Restaurant email'
        optional :description, type: String, desc: 'Restaurant description'
        optional :opening_hours, type: String, desc: 'Restaurant opening hours'
        optional :delivery_radius, type: Integer, desc: 'Restaurant delivery radius'
      end
      patch '/restaurant/update' do
        update_restaurant_details
      end

      desc 'Delete a restaurant'
      params do
        requires :id, type: Integer, desc: 'ID of the restaurant to delete'
      end
      delete 'restaurant/delete' do
        delete_restaurant
      end

    end
  end
end