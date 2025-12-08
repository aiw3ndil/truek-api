class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :title, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'available', null: false

      t.timestamps
    end
    
    add_index :items, :status
    add_index :items, [:user_id, :created_at]
  end
end
