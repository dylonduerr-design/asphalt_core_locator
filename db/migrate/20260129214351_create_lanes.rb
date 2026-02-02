class CreateLanes < ActiveRecord::Migration[7.1]
  def change
    create_table :lanes do |t|
      t.references :sublot, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :name
      t.decimal :length_ft, null: false, precision: 10, scale: 2
      t.decimal :width_ft, null: false, precision: 10, scale: 2

      t.timestamps
    end

    add_index :lanes, [:sublot_id, :position], unique: true
  end
end
