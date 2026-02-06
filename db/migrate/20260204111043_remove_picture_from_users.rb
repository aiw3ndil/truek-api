class RemovePictureFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :picture, :string
  end
end
