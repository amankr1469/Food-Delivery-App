require "application_system_test_case"

class RestaurantsTest < ApplicationSystemTestCase
  setup do
    @restaurant = restaurants(:one)
  end

  test "visiting the index" do
    visit restaurants_url
    assert_selector "h1", text: "Restaurants"
  end

  test "creating a Restaurant" do
    visit restaurants_url
    click_on "New Restaurant"

    fill_in "Contact number", with: @restaurant.contact_number
    fill_in "Delivery radius", with: @restaurant.delivery_radius
    fill_in "Description", with: @restaurant.description
    fill_in "Email", with: @restaurant.email
    fill_in "Location", with: @restaurant.location
    fill_in "Logo url", with: @restaurant.logo_url
    fill_in "Menu url", with: @restaurant.menu_url
    fill_in "Opening hours", with: @restaurant.opening_hours
    fill_in "Pincode", with: @restaurant.pincode
    fill_in "User", with: @restaurant.user_id
    click_on "Create Restaurant"

    assert_text "Restaurant was successfully created"
    click_on "Back"
  end

  test "updating a Restaurant" do
    visit restaurants_url
    click_on "Edit", match: :first

    fill_in "Contact number", with: @restaurant.contact_number
    fill_in "Delivery radius", with: @restaurant.delivery_radius
    fill_in "Description", with: @restaurant.description
    fill_in "Email", with: @restaurant.email
    fill_in "Location", with: @restaurant.location
    fill_in "Logo url", with: @restaurant.logo_url
    fill_in "Menu url", with: @restaurant.menu_url
    fill_in "Opening hours", with: @restaurant.opening_hours
    fill_in "Pincode", with: @restaurant.pincode
    fill_in "User", with: @restaurant.user_id
    click_on "Update Restaurant"

    assert_text "Restaurant was successfully updated"
    click_on "Back"
  end

  test "destroying a Restaurant" do
    visit restaurants_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Restaurant was successfully destroyed"
  end
end
