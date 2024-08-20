class ExportCsvJob
  include Sidekiq::Job
  sidekiq_options queue: 'report'
  
  def perform(user_id)
    csv_data = ExportRestaurantCsv.export_restaurants_to_csv(user_id)
    File.write(Rails.root.join('public', "restaurants #{user_id}-#{Date.current}.csv"), csv_data)
  end
end
