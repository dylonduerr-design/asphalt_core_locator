class AddPlantAndMixToLots < ActiveRecord::Migration[7.1]
  def change
    add_column :lots, :plant, :string
    add_column :lots, :mix_type, :string
    add_index :lots, [:plant, :mix_type, :lot_number]
    
    # Remove unique constraint on lot_number since we now allow duplicates across plants/mixes
    remove_index :lots, :lot_number
  end
end
