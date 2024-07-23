class UsersController < ApplicationController
  
  before_action :authenticate_request, only: [:profile, :update, :destroy]
  before_action :set_user, only: [:profile, :update, :destroy]

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_login_path
    else
      render :error
    end
  end

  def register
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
        redirect_to restaurants_path
      elsif @user.role == 'customer'
        redirect_to root_path
      else 
        redirect_to root_path
      end
      
    else
      error!('Unauthorized', 401)
      render :new
    end
  end
  
  def signout
    cookies.delete(:token)
    redirect_to users_login_path
  end

  def profile
    
  end

  def update
    if @user.update(edit_user_params)
      redirect_to root_path, notice: 'User details updated'
    else
      render :profile
    end
  end

  def destroy
    
  end

  private 

  def set_user 
    @user = @current_user
  end

  def user_params
    params.permit(:email, :password, :password_confirmation, :role)
  end

  def edit_user_params
    params.require(:user).permit(:name, :email)
  end
end
