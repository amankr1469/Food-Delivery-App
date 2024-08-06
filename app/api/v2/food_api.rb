module V2
  class FoodAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers FoodHelper
    helpers AuthHelper

    before { authenticate }
    before { admin_only }

     resources "/admin" do
       desc "Show food item details"
       params do
        requires :id, type: String, desc: 'Food ID'
       end
       get '/food' do
        get_food_details
       end

       desc "Update food item details"
       params do
        requires :id, type: String, desc: 'Food ID'
        optional :name, type: String, desc: 'Food name'
        optional :description, type: String, desc: 'Food description'
        optional :price, type: Integer, desc: 'Food price'
        optional :category, type: String, desc: 'Food category'
       end
       patch '/food/update' do
        update_food_details
       end

       desc "Delete food item"
       params do
        requires :id, type: String, desc: 'Food ID'
       end
       delete '/food/delete' do
         delete_the_food
       end

       desc "Create a Food Item"
       params do
        requires :name, type: String, desc: 'Food name'
        requires :description, type: String, desc: 'Food description'
        requires :price, type: Float, desc: 'Food price'
        requires :category, type: String, desc: 'Food category'
        requires :restaurant_id, type: Integer, desc: 'Restaurant ID'
       end
       post 'food/new' do
        create_food_item 
       end
     end
  end
end