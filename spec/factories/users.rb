FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { "john.doe@example.com" }
    password { "password" }
    password_confirmation { "password" }
    role { "admin" }
    contact_number { 0001 }
  end
end