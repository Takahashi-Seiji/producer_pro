class Client < ApplicationRecord
  has_many :orders, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
end
