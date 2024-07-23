class RatingDropTables < ActiveRecord::Migration[6.1]
  def change
    remove_column :foods, :raing, :float
  end
end
