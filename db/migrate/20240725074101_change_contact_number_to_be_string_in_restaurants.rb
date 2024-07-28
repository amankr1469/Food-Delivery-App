class ChangeContactNumberToBeStringInRestaurants < ActiveRecord::Migration[6.1]
  def up
    change_column :restaurants, :contact_number, :string
  end

  def down
    change_column :restaurants, :contact_number, :integer
  end
end
