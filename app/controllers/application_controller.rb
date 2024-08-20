class ApplicationController < ActionController::Base
  
  skip_before_action :verify_authenticity_token
  def check
    render html: "bhature with lassi"
  end

  private
  include JsonWebToken

  def authenticate_request
    token = cookies[:token]
  
    if token.blank?
      redirect_to users_login_path, alert: 'Please log in to continue.'
      return
    end
  
    begin
      decoded_token = JsonWebToken.decode(token)
      @current_user = User.find(decoded_token['user_id'])
  
      if @current_user.nil?
        redirect_to users_login_path, alert: 'Invalid user. Please log in again.'
      end
    rescue JWT::DecodeError
      redirect_to users_login_path, alert: 'Invalid token. Please log in again.'
    rescue ActiveRecord::RecordNotFound
      redirect_to users_login_path, alert: 'User not found. Please log in again.'
    rescue => e
      redirect_to users_login_path, alert: "An unexpected error: #{e.message}"
    end
  end
  

  def admin_only
    unless @current_user&.role == 'admin'
      gif_path = Rails.root.join('public', 'forbidden.gif')
      send_file gif_path, type: 'image/gif', disposition: 'inline'
    end
  end

end
