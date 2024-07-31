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
    unless @current_user&.role == 'admin'
      gif_path = Rails.root.join('public', 'forbidden.gif')
      send_file gif_path, type: 'image/gif', disposition: 'inline'
    end
  end

end
