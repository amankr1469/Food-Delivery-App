class Restaurant < ApplicationRecord
  has_many :foods, dependent: :destroy
  belongs_to :user

  validates :name, presence: true
  validates :location, presence: true
  validates :description, presence: true
  validates :opening_hours, presence: true
  validates :pincode, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 100000, less_than_or_equal_to: 999999 }
  validates :contact_number, presence: true, format: { 
  with: /\A\+?\d{1,3}?[-.\s]?\(?\d{1,4}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}\z/, 
  message: "only allows valid phone numbers" 
}

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :delivery_radius, presence: true, numericality: { only_integer: true, greater_than: 0 }

  has_one_attached :image, dependent: :destroy

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
