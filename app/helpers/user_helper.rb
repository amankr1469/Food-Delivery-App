module UserHelper
  def user_details(current_user)
      unless current_user
        error!({ message: 'Please sign in to access this page' }, 401)
      end
      user_data = current_user.attributes.except('password_digest')
      {message: 'User Details', user: user_data}
  end

  def logout_user
    cookies.delete(:token, path:'/') if cookies[:token]
    { message: 'Logged out successfully' }
  end

  def update_user_details(current_user)
    email = params[:email]
    name = params[:name]
    contact_number = params[:contact_number]

    if current_user.blank?
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
      if current_user.update!(user_params)
    { message: 'User details updated' }
    end
    rescue ActiveRecord::RecordInvalid => e
      error!({ message: e.record.errors.full_messages.join(', ') }, 422)
    rescue => e
      error!({ message: 'Failed to update user details' }, 500)
    end
  end

  def delete_user(current_user)
    if current_user.blank?
      error!({ message: 'User not found' }, 404)
    end
  
    begin
      current_user.delete
      { message: 'User was successfully destroyed' }
    rescue => e
      error!({ message: e.message }, 500)
    end
  end
end