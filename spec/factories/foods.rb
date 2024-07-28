FactoryBot.define do
  factory :food do
    name { "Pizza" }
    description { "A delicious pizza" }
    price { 10 }
    category { "Main Course" }
    association :restaurant, factory: :restaurant
  end
end
