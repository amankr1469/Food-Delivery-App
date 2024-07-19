require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = FactoryBot.create(:user)
    expect(user).to be_valid
  end

  it "is not valid without a name" do
    user = FactoryBot.create(:user, name: nil)
    expect(user).not_to be_valid
  end

  it "is not valid without an email" do
    user = FactoryBot.create(:user, email: nil)
    expect(user).not_to be_valid
  end
end
