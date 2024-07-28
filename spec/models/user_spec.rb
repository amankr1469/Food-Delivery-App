require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = FactoryBot.create(:user)
    expect(user).to be_valid
  end

  it "is not valid without a name" do
    user = FactoryBot.create(:user, name: nil)
    expect(user).to be_valid
  end

  it "is not valid without an email" do
    user = FactoryBot.build(:user, email: nil)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "is not valid with an invalid email" do
    user = FactoryBot.build(:user, email: 'invalid_email')
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  it 'is not valid with a duplicate email' do
    FactoryBot.create(:user, email: "amango@gmail.com")
    user = FactoryBot.build(:user, email: "amango@gmail.com")
    expect(user).not_to be_valid
  end
end
