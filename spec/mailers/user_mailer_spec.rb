require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'instructions' do
    let(:user) { FactoryBot.create(:user) }
    let(:checkout_mail) { UserMailer.checkout_email(user).deliver_now }
    let(:registered_mail) { UserMailer.registered_email(user).deliver_now }

    describe 'Order checkout mail' do
      it 'renders the subject' do
        expect(checkout_mail.subject).to eq('Your Order has been placed')
      end
  
      it 'renders the receiver email' do
        expect(checkout_mail.to).to eq([user.email])
      end
  
      it 'renders the sender email' do
        expect(checkout_mail.from).to eq(['no-reply@gofoodie.com'])
      end
    end

    describe 'When user registers mail' do
      it 'renders the subject' do
        expect(registered_mail.subject).to eq('Your account has begin successfully created')
      end
  
      it 'renders the receiver email' do
        expect(registered_mail.to).to eq([user.email])
      end
  
      it 'renders the sender email' do
        expect(registered_mail.from).to eq(['no-reply@gofoodie.com'])
      end
    end
  end
end
