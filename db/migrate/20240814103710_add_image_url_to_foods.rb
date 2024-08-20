class AddImageUrlToFoods < ActiveRecord::Migration[6.1]
  def change
    add_column :foods, :image_url, :string
  end
end
