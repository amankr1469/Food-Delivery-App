class Restaurant < ApplicationRecord
  # has_many :orders
  has_many :foods, dependent: :destroy
  belongs_to :user
  validates :name, presence: true
  validates :location, presence: true

  has_one_attached :image, dependent: :destroy
end
