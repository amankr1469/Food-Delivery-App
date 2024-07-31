module V2
  class AuthAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers AuthHelper

    resources '/auth' do
      desc 'Authenticate and get a token'
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end
      post '/login' do
        login_user
      end

      desc 'Register a new user'
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
        requires :password_confirmation, type: String, desc: 'Password confirmation'
        requires :role, type: String, desc: 'Role'
      end
      post '/register' do
        register_user
      end
    end
  end
end