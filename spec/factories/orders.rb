FactoryBot.define do
  factory :order do
    user { nil }
    food_quantities { "" }
    address { "MyString" }
    total_amount { "9.99" }
  end
end
