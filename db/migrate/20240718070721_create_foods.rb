class CreateFoods < ActiveRecord::Migration[6.1]
  def change
    create_table :foods do |t|
      t.string :name
      t.text :description
      t.integer :price
      t.integer :restaurant_id
      t.string :category
      t.float :raing
      t.string :image_url

      t.timestamps
    end
  end
end
