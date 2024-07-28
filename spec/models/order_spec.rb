require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:food_quantities) { { "3" => { "quantity" => 3 }, "4" => { "quantity" => 1 } }.to_json }  

  context 'validations' do
    it "is valid with valid attributes" do
      order = FactoryBot.build(:order, user: user, food_quantities: food_quantities, address: '123 Test St', total_amount: 50.0)
      expect(order).to be_valid
    end

    it "is not valid without a user_id" do
      order = FactoryBot.build(:order, user_id: nil, food_quantities: food_quantities, address: '123 Test St', total_amount: 50.0)
      expect(order).not_to be_valid
      expect(order.errors[:user_id]).to include("can't be blank")
    end

    it "is not valid without food_quantities" do
      order = FactoryBot.build(:order, user: user, food_quantities: nil, address: '123 Test St', total_amount: 50.0)
      expect(order).not_to be_valid
      expect(order.errors[:food_quantities]).to include("can't be blank")
    end

    it "is not valid without an address" do
      order = FactoryBot.build(:order, user: user, food_quantities: food_quantities, address: nil, total_amount: 50.0)
      expect(order).not_to be_valid
      expect(order.errors[:address]).to include("can't be blank")
    end

    it "is not valid without a total_amount" do
      order = FactoryBot.build(:order, user: user, food_quantities: food_quantities, address: '123 Test St', total_amount: nil)
      expect(order).not_to be_valid
      expect(order.errors[:total_amount]).to include("can't be blank")
    end

    it "is not valid with a negative total_amount" do
      order = FactoryBot.build(:order, user: user, food_quantities: food_quantities, address: '123 Test St', total_amount: -1.0)
      expect(order).not_to be_valid
      expect(order.errors[:total_amount]).to include("must be greater than or equal to 0")
    end

    it "is valid with a total_amount of zero" do
      order = FactoryBot.build(:order, user: user, food_quantities: food_quantities, address: '123 Test St', total_amount: 0.0)
      expect(order).to be_valid
    end

    it "is valid with a positive total_amount" do
      order = FactoryBot.build(:order, user: user, food_quantities: food_quantities, address: '123 Test St', total_amount: 50.0)
      expect(order).to be_valid
    end
  end
end
