class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.json :food_quantities
      t.string :address
      t.decimal :total_amount

      t.timestamps
    end
  end
end
