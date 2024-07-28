class ChangeContactNumberToBeStringInUsers < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :contact_number, :string
  end

  def down
    change_column :users, :contact_number, :integer
  end
end
