class RemoveImageUrlFromItemImages < ActiveRecord::Migration[7.1]
  def change
    remove_column :item_images, :image_url, :string
  end
end
