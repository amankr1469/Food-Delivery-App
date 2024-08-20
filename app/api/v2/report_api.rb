module V2
  class ReportAPI < Grape::API
    version 'v2', using: :path
    format :json

    helpers AuthHelper
    helpers ReportHelper

    resource '/admin' do
      desc 'Download CSV file'
      params do
        requires :user_id, type: Integer, desc: 'User ID'
      end
      get '/export_csv' do
        generate_report
      end
  
      desc 'Download generated CSV file'
      params do
        requires :user_id, type: Integer, desc: 'User ID'
      end
      get '/download_csv' do
        download_report
      end
    end
  end   
end