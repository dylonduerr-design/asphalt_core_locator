class AddRandomNumbersToCoreLocations < ActiveRecord::Migration[7.1]
  def change
    add_column :core_locations, :station_random_number, :decimal, precision: 10, scale: 4
    add_column :core_locations, :offset_random_number, :decimal, precision: 10, scale: 4
  end
end
