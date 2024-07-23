class UsersController < ApplicationController
  
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_login_path
    else
      render :error
    end
  end

  def profile
    
  end

  def register
  end

  def user_params
    puts params
    
    params.permit(:email, :password, :password_confirmation, :role)
  end

  def login
    
  end

  def signin
    @user = User.find_by(email: params[:email])

    if @user && @user.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      cookies[:token] = {
        value: token,
        expires: 7.hours.from_now,
        httponly: true,
      }

      if @user.role == 'admin'
        redirect_to restaurants_path, status: :ok
      elsif @user.role == 'customer'
        redirect_to root_path, status: :ok
      else 
        redirect_to root_path, status: :ok
      end
      
    else
      error!('Unauthorized', 401)
      render :new
    end
  end
  
  def signout
    cookies.delete(:token)
    redirect_to users_login_path, status: :ok
  end
end
