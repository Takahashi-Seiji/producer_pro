class AddMinStockToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :min_stock, :integer
  end
end
