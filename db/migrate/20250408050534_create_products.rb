class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :stock
      t.string :unit
      t.decimal :price_per_unit
      t.text :description

      t.timestamps
    end
  end
end
