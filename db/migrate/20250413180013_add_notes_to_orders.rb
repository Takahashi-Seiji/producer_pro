class AddNotesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :notes, :text
  end
end
