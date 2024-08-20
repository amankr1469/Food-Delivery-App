class UsersController < ApplicationController
  
  before_action :authenticate_request, only: [:profile, :update, :destroy]
  before_action :set_user, only: [:profile, :update, :destroy, :signout]

  def create
    existing_user = User.find_by(email: user_params[:email])
  
    if existing_user
      redirect_to users_register_path, notice: 'Email already exists'
    else
      @user = User.new(user_params)
  
      begin
        @user.save!
        RegisteredMailerJob.perform_in(1.hour, @user.id)
        redirect_to users_login_path, notice: 'User registered successfully'
      rescue ActiveRecord::RecordInvalid => e
        redirect_to users_register_path, notice: e.message
      rescue => e
        redirect_to users_register_path, notice: "An unexpected error occurred: #{e.message}"
      end
    end
  end
  
  def register
  end

  def login
    
  end

  def signin
    if params[:email].blank? || params[:password].blank?
      redirect_to users_login_path, alert: "Email and password must be provided"
      return
    end
  
    @user = User.find_by(email: params[:email])
  
    cookies.delete(:token) if cookies[:token]
  
    if @user && @user.authenticate(params[:password])
      begin
        token = JsonWebToken.encode(user_id: @user.id)
        cookies[:token] = {
          value: token,
          expires: 7.hours.from_now,
          httponly: true,
        }

        case @user.role
        when 'admin'
          redirect_to restaurants_path, notice: 'Signed in successfully as Admin'
        when 'customer'
          redirect_to root_path, notice: 'Signed in successfully'
        else
          redirect_to root_path, notice: 'Invalid user role'
        end
      rescue => e
        redirect_to users_login_path, notice: "An unexpected error occurred: #{e.message}"
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
  
    begin
      @user.update!(edit_user_params)
      if @user.image.attached?
        @user.update!(avatar: url_for(@user.image))
      end
      redirect_to root_path, notice: 'User details updated successfully'
    rescue ActiveRecord::RecordInvalid => e
      flash[:notice] = "Failed to update user details: #{e.message}"
      render :profile
    rescue => e
      flash[:notice] = "An unexpected error occurred: #{e.message}"
      render :profile
    end
  end
  

  def destroy
    if @user.nil?
      redirect_to users_login_path, notice: 'User not found'
      return
    end
  
    begin
      @user.destroy!
      redirect_to users_register_path, notice: 'User was successfully destroyed'
    rescue ActiveRecord::RecordNotDestroyed => e
      redirect_to users_login_path, notice: "Failed to destroy user: #{e.message}"
    rescue => e
      redirect_to users_login_path, notice: "An unexpected error occurred: #{e.message}"
    end
  end
  


  private 
  def set_user 
    @user = @current_user
  end

  def user_params
    params.permit(:email, :password, :password_confirmation, :role)
  end

  def edit_user_params
    params.require(:user).permit(:name, :email, :contact_number, :image)
  end
end
