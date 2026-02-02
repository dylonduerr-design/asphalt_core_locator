class AddLockedForCoreGenerationToSublots < ActiveRecord::Migration[7.1]
  def change
    add_column :sublots, :locked_for_core_generation, :boolean, null: false, default: false
    add_index :sublots, :locked_for_core_generation
  end
end
