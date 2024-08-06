# 50000.times do |i|
#   Food.create(
#     name: ["Cheese Cake #{i+1}", "Veg Burrito #{i+1}", "Taco #{i+1}", "Shawarma #{i+1}", "Burger #{i+1}"].sample,
#     description: "This is the description for food item #{i+1}.",
#     price: (5+ i), 
#     category: ["Appetizer", "Main Course", "Dessert", "Beverage"].sample, 
#     restaurant_id: 9
#   )
# end


# Create some admin
# 3.times do |i|
#   User.create(
#     name: "Admin #{i+1}",
#     email: "admin#{i+1}@gotest.com",
#     password: "password",
#     role: "admin",
#     contact_number: "9234567890"
#   )
# end



# 50000.times do |i|
#   Restaurant.create(
#     name: "Club & Bar#{i+1}",
#     location: "Location #{i+1}",
#     description: "This is a description for Club & Bar #{i+1}.",
#     opening_hours: "9:00 AM - 9:00 PM",
#     pincode: rand(100000..999999), 
#     contact_number: "+1-234-567-8910", 
#     email: "restaurant#{i+1}@example.com",
#     delivery_radius: rand(1..10), 
#     user_id: 22
#   )
# end
