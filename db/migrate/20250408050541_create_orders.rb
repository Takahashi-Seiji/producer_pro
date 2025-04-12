class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :client, null: false, foreign_key: true
      t.string :status
      t.decimal :total_price
      t.date :delivery_date

      t.timestamps
    end
  end
end
