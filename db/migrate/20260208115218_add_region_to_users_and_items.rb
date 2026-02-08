class AddRegionToUsersAndItems < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :region, :string
    add_column :items, :region, :string
    add_index :users, :region
    add_index :items, :region
  end
end
