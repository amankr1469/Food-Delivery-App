class ApplicationController < ActionController::Base
  
  skip_before_action :verify_authenticity_token
  def check
    render html: "bhature with lassi"
  end

  private
  include JsonWebToken

  def authenticate_request
    token = cookies[:token]
    if token
      decoded_token = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded_token['user_id'])
      @current_user
    else 
      redirect_to users_login_path, alert: 'Please log in to continue.'
    end
  end

  def admin_only
    render json: { error: 'Forbidden' }, status: :forbidden unless @current_user&.role == 'admin'
  end

end
