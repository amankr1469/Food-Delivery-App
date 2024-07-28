class UsersController < ApplicationController
  
  before_action :authenticate_request, only: [:profile, :update, :destroy]
  before_action :set_user, only: [:profile, :update, :destroy, :signout]

  def create
    existing_user = User.find_by(email: user_params[:email])
  
    if existing_user
      redirect_to users_register_path, notice: 'Email already exists'
    else
      @user = User.new(user_params)
  
      if @user.save
        redirect_to users_login_path
      else
        redirect_to users_register_path, notice: 'Choose strong credentials(Password: Minimun lenght 6)'
      end
    end
  end
  
  def register
  end

  def login
    
  end

  def signin
    if params[:email].blank? || params[:password].blank?
      redirect_to users_login_path, notice: "Email and password must be provided"
      return
    end

    @user = User.find_by(email: params[:email])

    cookies.delete(:token) if cookies[:token]

    if @user && @user.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      cookies[:token] = {
        value: token,
        expires: 7.hours.from_now,
        httponly: true,
      }

      case @user.role
      when 'admin'
        redirect_to restaurants_path
      when 'customer'
        redirect_to root_path
      else
        redirect_to root_path
      end

    else
      redirect_to users_login_path, notice: "Invalid Credentials"
    end
  end
  
  def signout
    cookies.delete(:token) if cookies[:token]
    redirect_to users_login_path
  end

  def profile
    unless @current_user
      redirect_to users_login_path, alert: 'Please sign in to access this page'
    end
  end

  def update
    if @user.nil?
      redirect_to users_signup_path, alert: 'User not found'
      return
    end

    if @user.update(edit_user_params)
      redirect_to root_path, notice: 'User details updated'
    else
      render :profile, notice: 'Failed to update user details'
    end
  end

  def destroy
    if @user.nil?
      redirect_to users_register_path, alert: 'User not found'
      return
    end

    @user.destroy
    redirect_to users_register_path, notice: 'User was successfully destroyed'
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
