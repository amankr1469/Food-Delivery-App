class UserMailer < ApplicationMailer
  default from: 'no-reply@gofoodie.com'

  def checkout_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your Order has been placed')
  end

  def registered_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your account has begin successfully created')
  end

  def food_in_cart(user)
    @user = user
    mail(to: @user.email, subject: 'Khaana thanda ho raha hai!')
  end
end
