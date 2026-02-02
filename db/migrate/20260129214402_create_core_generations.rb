class CreateCoreGenerations < ActiveRecord::Migration[7.1]
  def change
    create_table :core_generations do |t|
      t.references :lot, null: false, foreign_key: true
      t.string :seed
      t.decimal :rounding_increment_ft, null: false, default: 0.5, precision: 10, scale: 2
      t.decimal :mat_edge_buffer_ft, null: false, default: 1.0, precision: 10, scale: 2
      t.decimal :lane_start_buffer_ft, null: false, default: 10.0, precision: 10, scale: 2
      t.integer :mat_cores_per_sublot, null: false, default: 1
      t.integer :joint_cores_per_joint, null: false, default: 1

      t.timestamps
    end
  end
end
