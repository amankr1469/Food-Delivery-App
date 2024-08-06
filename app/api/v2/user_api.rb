module V2
  class UserAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers AuthHelper
    helpers UserHelper

    before { authenticate }

    resources '/user' do
      desc 'Show user profile'
      get '/profile' do
        user_details(@current_user)
      end

      #TODO
      desc 'Logout user'
      delete '/logout' do
        logout_user
      end

      #TODO - Role shouldn't change
      desc 'Update user profile'
      params do
        optional :name, type: String, desc: 'Name'
        optional :email, type: String, desc: 'Email' 
        optional :contact_number, type: String, desc: 'Contact Number'
      end
      patch '/update' do
        update_user_details(@current_user)
      end

      desc 'Delete user account'
      delete '/delete' do
        delete_user(@current_user)
      end
    end
  end
end