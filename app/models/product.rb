class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :product_raw_materials, dependent: :destroy
  has_many :raw_materials, through: :product_raw_materials
  
  validates :name, presence: true
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true
  validates :price_per_unit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_destroy :check_for_orders
  
  private
  
  def check_for_orders
    if orders.any?
      errors.add(:base, 'Cannot delete product with existing orders')
      throw :abort
    end
  end
end
