require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  context 'validations' do
    it "is valid with valid attributes" do
      restaurant = FactoryBot.build(:restaurant)
      expect(restaurant).to be_valid
    end

    it "is not valid without a name" do
      restaurant = FactoryBot.build(:restaurant, name: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a location" do
      restaurant = FactoryBot.build(:restaurant, location: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:location]).to include("can't be blank")
    end

    it "is not valid without a pincode" do
      restaurant = FactoryBot.build(:restaurant, pincode: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:pincode]).to include("can't be blank")
    end

    it "is not valid without a contact number" do
      restaurant = FactoryBot.build(:restaurant, contact_number: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:contact_number]).to include("can't be blank")
    end

    it "is not valid without an email" do
      restaurant = FactoryBot.build(:restaurant, email: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:email]).to include("can't be blank")
    end

    it "is not valid without a description" do
      restaurant = FactoryBot.build(:restaurant, description: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:description]).to include("can't be blank")
    end

    it "is not valid without opening hours" do
      restaurant = FactoryBot.build(:restaurant, opening_hours: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:opening_hours]).to include("can't be blank")
    end

    it "is not valid without a delivery radius" do
      restaurant = FactoryBot.build(:restaurant, delivery_radius: nil)
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:delivery_radius]).to include("can't be blank")
    end

    it "is not valid with an invalid pincode format" do
      restaurant = FactoryBot.build(:restaurant, pincode: 'invalid')
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:pincode]).to include("is not a number")
    end

    it "is not valid with an invalid email format" do
      invalid_emails = [
        'plainaddress',
        '@missingusername.com',
        'user@.com',
      ]
      invalid_emails.each do |email|
        restaurant = FactoryBot.build(:restaurant, email: email)
        expect(restaurant).not_to be_valid
        expect(restaurant.errors[:email]).to include("is invalid")
      end
    end

    it "is valid with a correct phone number format" do
      valid_numbers = [
        '+1-800-555-5555',
        '+44 20 7946 0958',
        '555-5555',
        '5555555555',
        '+91 (22) 5555-5555'
      ]
      valid_numbers.each do |number|
        restaurant = FactoryBot.build(:restaurant, contact_number: number)
        expect(restaurant).to be_valid
      end
    end

    it "is valid with a correct email format" do
      valid_emails = [
        'restaurant@example.com',
        'user@domain.com',
        'user.name@domain.co'
      ]
      valid_emails.each do |email|
        restaurant = FactoryBot.build(:restaurant, email: email)
        expect(restaurant).to be_valid
      end
    end

    it "is valid with a valid pincode format" do
      valid_pincodes = [
        '123456',
        '987654',
      ]
      valid_pincodes.each do |pincode|
        restaurant = FactoryBot.build(:restaurant, pincode: pincode)
        expect(restaurant).to be_valid
      end
    end

  end
end
