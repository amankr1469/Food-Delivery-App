require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe CheckoutMailerJob, type: :job do
  let(:user) { FactoryBot.create(:user) }

  describe 'Jobs are enqueuing' do
    before do
      Sidekiq::Testing.fake!
    end

    it 'jobs get queued' do
      expect { CheckoutMailerJob.perform_async(user.id) }
            .to change { CheckoutMailerJob.jobs.size }.by(1) 
    end

    it 'in the correct queue' do
      jid = CheckoutMailerJob.perform_async(user.id)
      job_check = CheckoutMailerJob.jobs.find{ |j| j['jid'] == jid }
      expect(job_check).not_to be_nil
      expect(job_check['queue']).to eq('mailer')
    end
  end

  describe 'When user registers' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it 'sends an email' do
      Sidekiq::Testing.inline! do
        CheckoutMailerJob.perform_async(user.id)
      end
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    after do
      Sidekiq::Testing.fake!
    end
  end
end
