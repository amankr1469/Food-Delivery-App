class RemoveImageFromRestaurants < ActiveRecord::Migration[6.1]
  def change
    remove_column :restaurants, :image, :string
  end
end
