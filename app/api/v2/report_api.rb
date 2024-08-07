module V2
  class ReportAPI < Grape::API
    version 'v2', using: :path
    format :json

    helpers AuthHelper

    before { authenticate }

    desc 'Download CSV file'
    get '/export_csv' do
      
      ExportCsvJob.perform_async(@current_user.id)
      { message: 'CSV export job has been enqueued' }
    end

    # desc 'Download generated CSV file'
    # get '/download_csv' do
    #   file_path = Rails.root.join('public', 'restaurants.csv')
    #   if File.exist?(file_path)
    #     env['api.format'] = :binary
    #     content_type 'text/csv'
    #     header['Content-Disposition'] = "attachment; filename=restaurants.csv"
    #     File.read(file_path)
    #   else
    #     error!('File not found', 404)
    #   end
    # end
  end   
end