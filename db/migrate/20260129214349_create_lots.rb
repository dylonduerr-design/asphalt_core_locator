class CreateLots < ActiveRecord::Migration[7.1]
  def change
    create_table :lots do |t|
      t.string :lot_number, null: false
      t.string :contractor
      t.string :mix_design
      t.string :pg
      t.string :description
      t.date :paving_date

      t.timestamps
    end

    add_index :lots, :lot_number, unique: true
  end
end
