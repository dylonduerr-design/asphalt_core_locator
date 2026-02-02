class CreateCoreLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :core_locations do |t|
      t.references :core_generation, null: false, foreign_key: true
      t.references :lot, null: false, foreign_key: true
      t.references :sublot, null: false, foreign_key: true
      t.integer :core_type, null: false
      t.references :lane, null: false, foreign_key: true
      t.bigint :left_lane_id
      t.bigint :right_lane_id
      t.integer :lane_index
      t.decimal :linear_in_sublot_ft, null: false, precision: 12, scale: 2
      t.decimal :station_in_lane_ft, null: false, precision: 12, scale: 2
      t.decimal :offset_in_lane_ft, null: false, precision: 12, scale: 2
      t.decimal :distance_from_lot_start_ft, null: false, precision: 12, scale: 2
      t.string :mark

      t.timestamps
    end

    add_index :core_locations, :left_lane_id
    add_index :core_locations, :right_lane_id
  end
end
