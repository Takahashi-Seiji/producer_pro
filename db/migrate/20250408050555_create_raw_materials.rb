class CreateRawMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :raw_materials do |t|
      t.string :name
      t.integer :stock
      t.string :unit
      t.decimal :cost_per_unit

      t.timestamps
    end
  end
end
