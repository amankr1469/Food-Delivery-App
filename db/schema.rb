
ActiveRecord::Schema.define(version: 2024_07_18_095541) do

  enable_extension "plpgsql"

  create_table "foods", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "price"
    t.integer "restaurant_id"
    t.string "category"
    t.float "raing"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "homes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "restaurants", force: :cascade do |t|
    t.integer "user_id"
    t.string "location"
    t.integer "pincode"
    t.integer "contact_number"
    t.string "email"
    t.text "description"
    t.string "opening_hours"
    t.integer "delivery_radius"
    t.string "logo_url"
    t.string "menu_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.integer "contact_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "AddLastnameToUsers"
    t.string "lastname"
    t.string "firstname"
  end

end
