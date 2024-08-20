class RemoveImageFromFoods < ActiveRecord::Migration[6.1]
  def change
    remove_column :foods, :image, :string
  end
end
