module AuthHelpers
  def sign_in(user)
    post users_signin_path, params: { email: user.email, password: 'password' }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
