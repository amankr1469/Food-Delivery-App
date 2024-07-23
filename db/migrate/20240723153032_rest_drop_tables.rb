class RestDropTables < ActiveRecord::Migration[6.1]
  def change
    remove_column :restaurants, :menu_url, :string
    remove_column :restaurants, :logo_url, :string
    remove_column :restaurants, :user_id, :integer
  end
end
