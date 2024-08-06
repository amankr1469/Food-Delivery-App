module AuthHelpers
  def sign_in(user)
    post users_signin_path, params: { email: user.email, password: 'password' }
  end

  def admin_only(user)
    unless user.role == 'admin'
      error!({ message: 'Access denied' }, 403)
    end
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
