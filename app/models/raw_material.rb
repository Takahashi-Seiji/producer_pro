class RawMaterial < ApplicationRecord
  has_many :product_raw_materials, dependent: :destroy
  has_many :products, through: :product_raw_materials

  validates :name, presence: true
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true
  validates :cost_per_unit, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
