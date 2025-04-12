class CreateProductRawMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :product_raw_materials do |t|
      t.references :product, null: false, foreign_key: true
      t.references :raw_material, null: false, foreign_key: true
      t.decimal :quantity_required, precision: 10, scale: 2, null: false
      t.string :unit, null: false

      t.timestamps
    end

    add_index :product_raw_materials, [:product_id, :raw_material_id], unique: true
  end
end
