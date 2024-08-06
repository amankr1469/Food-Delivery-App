FactoryBot.define do
  factory :food do
    id { SecureRandom.uuid }
    name { "Pizza" }
    description { "A delicious pizza" }
    price { 10 }
    category { "Main Course" }
    association :restaurant, factory: :restaurant
  end
end
