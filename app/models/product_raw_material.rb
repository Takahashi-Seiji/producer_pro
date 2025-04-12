class ProductRawMaterial < ApplicationRecord
  belongs_to :product
  belongs_to :raw_material

  validates :quantity_required, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :raw_material_id, uniqueness: { scope: :product_id }
end 