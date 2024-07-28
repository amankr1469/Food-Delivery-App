class Order < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :food_quantities, presence: true
  validates :address, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  private
end
