class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :contact_number, format: { with: /\A\+?\d{1,3}?[-.\s]?\(?\d{1,4}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}\z/, message: "only allows valid phone numbers" }, length: { minimum: 10 }, allow_nil: true
  validates :role, presence: true, inclusion: { in: %w(customer admin delivery) }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  has_one_attached :image, dependent: :destroy

  before_save :downcase_email

  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
