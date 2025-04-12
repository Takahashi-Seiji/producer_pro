class Income < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :source, presence: true
end
