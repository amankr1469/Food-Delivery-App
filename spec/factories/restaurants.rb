FactoryBot.define do
  factory :restaurant do
    name { "Test Restaurant" }
    location { "123 Test St" }
    pincode { "123456" }
    contact_number { "9876543210" }
    email { "restaurant@example.com" }
    description { "A test restaurant" }
    opening_hours { "9 AM - 9 PM" }
    delivery_radius { 5 }
    association :user, factory: :user
  end
end
