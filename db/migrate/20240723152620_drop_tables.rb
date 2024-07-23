class DropTables < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :AddLastnameToUsers, :string
    remove_column :users, :lastname, :string
    remove_column :users, :firstname, :string
  end
end
