class CreateItemImages < ActiveRecord::Migration[7.1]
  def change
    create_table :item_images do |t|
      t.references :item, null: false, foreign_key: true
      t.string :image_url, null: false
      t.integer :position, default: 0

      t.timestamps
    end
    
    add_index :item_images, [:item_id, :position]
  end
end
