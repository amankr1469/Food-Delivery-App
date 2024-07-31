module V2
  class AuthAPI < Grape::API
    version 'v2', using: :path
    format :json
    helpers AuthHelper
    include JsonWebToken

    resources '/auth' do
      desc 'Authenticate and get a token'
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end

      post '/login' do
        if params[:email].blank? || params[:password].blank?
          error!({ message: 'Email and password must be provided' }, 400)
        end

        @user = User.find_by(email: params[:email])

        if @user && @user.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)

          cookies[:token] = {
            value: token,
            expires: 7.hour.from_now,
            httponly: true,
          }

          { message: 'Logged in successfully', token: token }
        else
          error!('Unauthorized', 401)
        end
      end

      desc 'Register a new user'
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
        requires :password_confirmation, type: String, desc: 'Password confirmation'
        requires :role, type: String, desc: 'Role'
      end

      post '/register' do
        email = params[:email]
        password = params[:password]
        password_confirmation = params[:password_confirmation]
        role = params[:role]
        
        if email.blank? || password.blank?
          error!({ message: 'Email and password must be provided' }, 400)
        end

        if password.length < 6
          error!({ message: 'Password is too short' }, 409)
        end

        if password != password_confirmation
          error!({ message: 'Password and Password Confirmation are not the same' }, 409)
        end
      
        if role.blank?
          error!({ message: 'Role must be provided' }, 409)
        end

        unless ['customer', 'admin', 'delivery'].include?(role)
          error!({ message: "Invalid role" }, 409)
        end
      
        existing_user = User.find_by(email: params[:email])
      
        if existing_user
          error!({ message: 'Email already exists' }, 409)
        else
          @user = User.new(
            email: params[:email],
            password: params[:password],
            password_confirmation: params[:password_confirmation],
            role: params[:role]
          )
      
          begin
            @user.save!
            { message: 'User registered successfully' }
          rescue ActiveRecord::RecordInvalid => e
            error!({ message: e.message }, 422)
          end
        end
      end

    end

    before { authenticate }

    resources '/user' do
      desc 'Show user profile'
      get :profile do
        unless @current_user
          error!({ message: 'Please sign in to access this page' }, 401)
        end
        user_data = @current_user.attributes.except('password_digest')
        {message: 'User Details', user: user_data}
      end

      #TODO
      desc 'Logout user'
      delete '/logout' do
        cookies.delete(:token) if cookies[:token]
        { message: 'Logged out successfully' }
      end

      desc 'Update user profile'
      params do
        requires :name, type: String, desc: 'Name'
        requires :email, type: String, desc: 'Email' 
        optional :contact_number, type: String, desc: 'Contact Number'
      end
      patch '/update' do
        email = params[:email]
        name = params[:name]
        contact_number = params[:contact_number]

        if @current_user.blank?
          error!({ message: 'You are not logged in' }, 401)
        end

        unless email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
          error!({ message: 'Invalid email format' }, 422)
        end

        if name.blank?
          error!({ message: 'Name cannot be blank' }, 422)
        end

        user_params = {}
        user_params[:email] = email
        user_params[:name] = name if name.present?
        user_params[:contact_number] = contact_number if contact_number.present?

        begin
          if @current_user.update!(user_params)
        { message: 'User details updated' }
        end
        rescue ActiveRecord::RecordInvalid => e
          error!({ message: e.record.errors.full_messages.join(', ') }, 422)
        rescue StandardError => e
          error!({ message: 'Failed to update user details' }, 500)
        end
      end

      desc 'Delete user account'
      delete '/delete' do
        if @current_user.blank?
          error!({ message: 'User not found' }, 404)
        end

        if @current_user.id != params[:id].to_i
          error!({ message: 'Unauthorized action' }, 403)
        end
      
        begin
          @current_user.delete!
          { message: 'User was successfully destroyed' }
        rescue ActiveRecord::RecordNotDestroyed => e
          error!({ message: 'Failed to destroy user. Please try again later.' }, 422)
        rescue StandardError => e
          error!({ message: 'An unexpected error occurred. Please try again later.' }, 500)
        end
      end
    end
  end
end