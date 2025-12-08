class CreateTrades < ActiveRecord::Migration[7.1]
  def change
    create_table :trades do |t|
      t.references :proposer, null: false, foreign_key: { to_table: :users }
      t.references :proposer_item, null: false, foreign_key: { to_table: :items }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :receiver_item, null: false, foreign_key: { to_table: :items }
      t.string :status, default: 'pending', null: false

      t.timestamps
    end
    
    add_index :trades, [:proposer_id, :receiver_id]
    add_index :trades, :status
  end
end
