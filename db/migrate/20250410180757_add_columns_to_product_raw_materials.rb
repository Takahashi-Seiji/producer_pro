class AddColumnsToProductRawMaterials < ActiveRecord::Migration[7.1]
  def change
    add_reference :product_raw_materials, :product, null: false, foreign_key: true
    add_reference :product_raw_materials, :raw_material, null: false, foreign_key: true
    add_column :product_raw_materials, :quantity_required, :decimal, precision: 10, scale: 2, null: false
    add_column :product_raw_materials, :unit, :string, null: false
    add_index :product_raw_materials, [:product_id, :raw_material_id], unique: true
  end
end
