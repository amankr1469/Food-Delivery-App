FactoryBot.define do
  factory :order do
    association :user, factory: :user
    food_quantities { { "1" => 2, "2" => 3 } }
    address { "123 Order St" }
    total_amount { 50.00 }
  end
end
