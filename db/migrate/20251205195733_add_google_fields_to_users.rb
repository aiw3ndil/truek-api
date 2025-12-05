class AddGoogleFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_id, :string
    add_column :users, :picture, :string
    add_column :users, :provider, :string, default: 'email'
    
    add_index :users, :google_id, unique: true
  end
end
