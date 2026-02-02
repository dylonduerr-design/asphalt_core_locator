class CreateSublots < ActiveRecord::Migration[7.1]
  def change
    create_table :sublots do |t|
      t.references :lot, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :name

      t.timestamps
    end

    add_index :sublots, [:lot_id, :position], unique: true
  end
end
