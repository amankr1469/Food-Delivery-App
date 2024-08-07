class CheckoutMailerJob
  include Sidekiq::Job
  sidekiq_options queue: 'mailer'

  def perform(user_id)
    user = User.select(:name, :email).find(user_id)
    UserMailer.checkout_email(user).deliver_now
  end
end

