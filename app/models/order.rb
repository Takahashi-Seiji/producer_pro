class Order < ApplicationRecord
  belongs_to :client
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  
  accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: :all_blank
  
  enum status: { pending: 'pending', confirmed: 'confirmed', delivered: 'delivered', cancelled: 'cancelled' }
  
  validates :status, presence: true
  validates :delivery_date, presence: true
  validates :order_items, presence: true
  
  before_validation :set_order_item_prices
  before_validation :calculate_total_price
  
  # Calendar configuration
  def start_time
    delivery_date
  end
  
  private
  
  def set_order_item_prices
    order_items.each do |item|
      item.unit_price = item.product.price_per_unit if item.product
    end
  end
  
  def calculate_total_price
    self.total_price = order_items.sum { |item| item.quantity * item.unit_price }
  end
end
