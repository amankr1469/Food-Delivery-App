class UserMailer < ApplicationMailer
  default from: 'no-reply@gofoodie.com'

  def checkout_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your Order has been placed')
  end
end
