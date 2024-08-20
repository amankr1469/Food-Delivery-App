class FoodCartMailerJob
  include Sidekiq::Job
  sidekiq_options queue: 'cart'
  
  def perform(user_id)
    user = User.select(:name, :email).find(user_id)
    UserMailer.food_in_cart(user).deliver_now
  end
end