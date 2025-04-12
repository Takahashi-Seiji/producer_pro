class Expense < ApplicationRecord
  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :category, presence: true
end
