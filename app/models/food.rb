class Food < ApplicationRecord
  belongs_to :restaurant

  has_one_attached :food_image, dependent: :destroy
end
