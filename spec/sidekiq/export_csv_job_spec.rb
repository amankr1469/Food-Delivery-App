require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ExportCsvJob, type: :job do
  let(:user) { FactoryBot.create(:user) }
  let(:csv_content) { "ID,Name,Email,Description\n1,Test Restaurant,test@example.com,Test description\n" }
  let(:file_path) { Rails.root.join('public', "restaurants_#{Date.current}.csv") }

  before do
    allow(ExportRestaurantCsv).to receive(:export_restaurants_to_csv).and_return(csv_content)
    File.delete(file_path) if File.exist?(file_path)
  end

  describe 'Jobs are enqueuing' do
    before do
      Sidekiq::Testing.fake!
    end

    it 'jobs get queued' do
      expect { ExportCsvJob.perform_async(user.id) }
            .to change { ExportCsvJob.jobs.size }.by(1) 
    end

    it 'in the correct queue' do
      jid = ExportCsvJob.perform_async(user.id)
      job_check = ExportCsvJob.jobs.find{ |j| j['jid'] == jid }
      expect(job_check).not_to be_nil
      expect(job_check['queue']).to eq('report')
    end
  end

  describe 'enqueue job' do
    before do
      Sidekiq::Testing.inline!
    end

    it 'executes the job immediately' do
      ExportCsvJob.perform_async(user.id)
      File.write(file_path, csv_content)
      expect(file_path.nil?).to be false
      expect(File.read(file_path)).to eq(csv_content)
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
      Sidekiq::Testing.fake!
    end
  end
end
