FactoryBot.define do
  factory :user do
    name { "Aman Kumar" }
    email { "aman.go@text.com" }
    password { "password" }
    password_confirmation { "password" }
    role { "admin" }
    contact_number { 9876543210 }
  end
end