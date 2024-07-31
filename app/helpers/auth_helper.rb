require 'jwt'

module AuthHelper
  include JsonWebToken
  
  def login_user
    if params[:email].blank? || params[:password].blank?
      error!({ message: 'Email and password must be provided' }, 400)
    end

    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)

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

  def register_user
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

  def authenticate
    token = cookies[:token]
    
    if token
      token = cookies[:token] 
      if token
        decoded_token = JsonWebToken.decode(token)
        @current_user = User.find_by(id: decoded_token['user_id'])
        @current_user
      else 
        redirect_to users_login_path, alert: 'Please log in to continue.'
      end
    end
  end
  
  def admin_only
    error!({ message: 'Access denied' }, 403) unless @current_user&.role == 'admin'
  end
end
