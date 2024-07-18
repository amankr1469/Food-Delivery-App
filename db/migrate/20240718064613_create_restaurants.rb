class CreateRestaurants < ActiveRecord::Migration[6.1]
  def change
    create_table :restaurants do |t|
      t.integer :user_id
      t.string :location
      t.integer :pincode
      t.integer :contact_number
      t.string :email
      t.text :description
      t.string :opening_hours
      t.integer :delivery_radius
      t.string :logo_url
      t.string :menu_url

      t.timestamps
    end
  end
end
