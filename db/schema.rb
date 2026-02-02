# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_30_003907) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "astm_random_numbers", force: :cascade do |t|
    t.integer "row", null: false
    t.integer "column", null: false
    t.decimal "value", precision: 10, scale: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["row", "column"], name: "index_astm_random_numbers_on_row_and_column", unique: true
  end

  create_table "core_generations", force: :cascade do |t|
    t.bigint "lot_id", null: false
    t.string "seed"
    t.decimal "rounding_increment_ft", precision: 10, scale: 2, default: "0.5", null: false
    t.decimal "mat_edge_buffer_ft", precision: 10, scale: 2, default: "1.0", null: false
    t.decimal "lane_start_buffer_ft", precision: 10, scale: 2, default: "10.0", null: false
    t.integer "mat_cores_per_sublot", default: 1, null: false
    t.integer "joint_cores_per_joint", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_id"], name: "index_core_generations_on_lot_id"
  end

  create_table "core_locations", force: :cascade do |t|
    t.bigint "core_generation_id", null: false
    t.bigint "lot_id", null: false
    t.bigint "sublot_id", null: false
    t.integer "core_type", null: false
    t.bigint "lane_id", null: false
    t.bigint "left_lane_id"
    t.bigint "right_lane_id"
    t.integer "lane_index"
    t.decimal "linear_in_sublot_ft", precision: 12, scale: 2, null: false
    t.decimal "station_in_lane_ft", precision: 12, scale: 2, null: false
    t.decimal "offset_in_lane_ft", precision: 12, scale: 2, null: false
    t.decimal "distance_from_lot_start_ft", precision: 12, scale: 2, null: false
    t.string "mark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "station_random_number", precision: 10, scale: 4
    t.decimal "offset_random_number", precision: 10, scale: 4
    t.index ["core_generation_id"], name: "index_core_locations_on_core_generation_id"
    t.index ["lane_id"], name: "index_core_locations_on_lane_id"
    t.index ["left_lane_id"], name: "index_core_locations_on_left_lane_id"
    t.index ["lot_id"], name: "index_core_locations_on_lot_id"
    t.index ["right_lane_id"], name: "index_core_locations_on_right_lane_id"
    t.index ["sublot_id"], name: "index_core_locations_on_sublot_id"
  end

  create_table "lanes", force: :cascade do |t|
    t.bigint "sublot_id", null: false
    t.integer "position", null: false
    t.string "name"
    t.decimal "length_ft", precision: 10, scale: 2, null: false
    t.decimal "width_ft", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sublot_id", "position"], name: "index_lanes_on_sublot_id_and_position", unique: true
    t.index ["sublot_id"], name: "index_lanes_on_sublot_id"
  end

  create_table "lots", force: :cascade do |t|
    t.string "lot_number", null: false
    t.string "contractor"
    t.string "mix_design"
    t.string "pg"
    t.string "description"
    t.date "paving_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plant"
    t.string "mix_type"
    t.index ["plant", "mix_type", "lot_number"], name: "index_lots_on_plant_and_mix_type_and_lot_number"
  end

  create_table "sublots", force: :cascade do |t|
    t.bigint "lot_id", null: false
    t.integer "position", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked_for_core_generation", default: false, null: false
    t.index ["locked_for_core_generation"], name: "index_sublots_on_locked_for_core_generation"
    t.index ["lot_id", "position"], name: "index_sublots_on_lot_id_and_position", unique: true
    t.index ["lot_id"], name: "index_sublots_on_lot_id"
  end

  add_foreign_key "core_generations", "lots"
  add_foreign_key "core_locations", "core_generations"
  add_foreign_key "core_locations", "lanes"
  add_foreign_key "core_locations", "lots"
  add_foreign_key "core_locations", "sublots"
  add_foreign_key "lanes", "sublots"
  add_foreign_key "sublots", "lots"
end
