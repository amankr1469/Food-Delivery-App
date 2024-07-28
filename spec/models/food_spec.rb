require 'rails_helper'

RSpec.describe Food, type: :model do
  let(:restaurant) { FactoryBot.create(:restaurant) }

  context 'validations' do
    it "is valid with valid attributes" do
      food = FactoryBot.build(:food, restaurant: restaurant)
      expect(food).to be_valid
    end

    # Testing for missing attributes
    it "is not valid without a name" do
      food = FactoryBot.build(:food, name: nil, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:name]).to include("can't be blank")
    end

    it "is not valid with a name shorter than 2 characters" do
      food = FactoryBot.build(:food, name: 'A', restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:name]).to include("is too short (minimum is 2 characters)")
    end

    it "is not valid with a name longer than 100 characters" do
      long_name = 'A' * 101
      food = FactoryBot.build(:food, name: long_name, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:name]).to include("is too long (maximum is 100 characters)")
    end

    it "is not valid without a description" do
      food = FactoryBot.build(:food, description: nil, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:description]).to include("can't be blank")
    end

    it "is not valid with a description shorter than 10 characters" do
      food = FactoryBot.build(:food, description: 'Too short', restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:description]).to include("is too short (minimum is 10 characters)")
    end

    it "is not valid with a description longer than 1000 characters" do
      long_description = 'A' * 1001
      food = FactoryBot.build(:food, description: long_description, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:description]).to include("is too long (maximum is 1000 characters)")
    end

    it "is not valid without a price" do
      food = FactoryBot.build(:food, price: nil, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:price]).to include("can't be blank")
    end

    it "is not valid with a price less than or equal to 0" do
      food = FactoryBot.build(:food, price: 0, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:price]).to include("must be greater than 0")
    end

    it "is not valid without a category" do
      food = FactoryBot.build(:food, category: nil, restaurant: restaurant)
      expect(food).not_to be_valid
      expect(food.errors[:category]).to include("can't be blank")
    end

    it "is not valid without a restaurant_id" do
      food = FactoryBot.build(:food, restaurant_id: nil)
      expect(food).not_to be_valid
      expect(food.errors[:restaurant_id]).to include("can't be blank")
    end

    # Testing for correctly formatted attributes
    it "is valid with a name of correct length" do
      valid_names = ['Burger', 'Cheeseburger', 'Chicken Sandwich']
      valid_names.each do |name|
        food = FactoryBot.build(:food, name: name, restaurant: restaurant)
        expect(food).to be_valid
      end
    end

    it "is valid with a description of correct length" do
      valid_descriptions = [
        'Delicious burger with cheese and bacon',
        'Spicy chicken sandwich with extra sauce',
        'Classic cheeseburger with lettuce and tomato'
      ]
      valid_descriptions.each do |description|
        food = FactoryBot.build(:food, description: description, restaurant: restaurant)
        expect(food).to be_valid
      end
    end

    it "is valid with a positive price" do
      valid_prices = [1, 10, 20, 50]
      valid_prices.each do |price|
        food = FactoryBot.build(:food, price: price, restaurant: restaurant)
        expect(food).to be_valid
      end
    end

    it "is valid with a non-blank category" do
      valid_categories = ['Appetizer', 'Main Course', 'Dessert']
      valid_categories.each do |category|
        food = FactoryBot.build(:food, category: category, restaurant: restaurant)
        expect(food).to be_valid
      end
    end
  end
end
