require 'jwt'

module AuthHelper
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
    error!({ message: 'Access denied' }, 403) unless current_user&.role == 'admin'
  end
end
