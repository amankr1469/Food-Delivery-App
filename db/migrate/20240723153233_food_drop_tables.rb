class FoodDropTables < ActiveRecord::Migration[6.1]
  def change
    remove_column :foods, :restaurant_id, :integer
    remove_column :foods, :image_url, :string
  end
end

