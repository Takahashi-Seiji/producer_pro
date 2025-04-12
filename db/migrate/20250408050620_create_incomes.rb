class CreateIncomes < ActiveRecord::Migration[7.1]
  def change
    create_table :incomes do |t|
      t.decimal :amount
      t.date :date
      t.string :source
      t.text :notes

      t.timestamps
    end
  end
end
