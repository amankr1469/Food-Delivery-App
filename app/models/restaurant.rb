class Restaurant < ApplicationRecord
  # has_many :orders
  has_many :foods, dependent: :destroy

  validates :name, presence: true
  validates :location, presence: true
end
