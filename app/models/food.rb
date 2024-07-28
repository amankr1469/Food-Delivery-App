class Food < ApplicationRecord
  belongs_to :restaurant

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :restaurant_id, presence: true

  has_one_attached :image, dependent: :destroy
end
