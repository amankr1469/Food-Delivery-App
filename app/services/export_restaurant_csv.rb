require 'csv'

class ExportRestaurantCsv
  def self.export_restaurants_to_csv(user_id)
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Name', 'Email', 'Description']
      Restaurant.where(user_id: user_id).find_each do |restaurant|
        csv << [restaurant.id, restaurant.name, restaurant.email, restaurant.description]
      end
    end
  end
end