require 'rails_helper'
require 'auth_helpers'

RSpec.describe "HomesController", type: :request do
  let(:user) { FactoryBot.create(:user, password: 'password') }
  let(:food) { FactoryBot.create(:food) }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
  end

  describe "GET /index" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /add_to_cart" do
    it "adds an item to the cart for authenticated users" do
      sign_in(user) 
      post users_add_path, params: { food_id: 1 }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Item added to cart.")
    end

    it "redirects to login for unauthenticated users" do
      post users_add_path, params: { food_id: food.id }
      expect(response).to redirect_to(users_login_path)
      follow_redirect!
    end
  end

  describe "POST /remove_from_cart" do
    it "removes an item from the cart for authenticated users" do
      sign_in(user)
      post users_remove_path, params: { food_id: 1 }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Item removed from cart.")
    end

    it "redirects to login for unauthenticated users" do
      post users_remove_path, params: { food_id: 1 }
      expect(response).to redirect_to(users_login_path)
      follow_redirect!
    end
  end

  describe "GET /cart" do
    it "returns http success for authenticated users" do
      sign_in(user) 
      get users_cart_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to login for unauthenticated users" do
      get users_cart_path
      expect(response).to redirect_to(users_login_path)
      follow_redirect!
    end
  end

  describe "POST /checkout" do
    it "places an order for authenticated users with valid data" do
      sign_in(user)
      post users_checkout_path, params: { address: '123 Test St' }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Order placed successfully.")
    end

    it "redirects to login for unauthenticated users" do
      post users_checkout_path, params: { address: '123 Test St' }, headers: { "HTTP_REFERER" => users_cart_path }
      expect(response).to redirect_to(users_login_path)
      follow_redirect!
      expect(response.body).to include("You need to log in to place an order.")
    end

    it "redirects to the cart page if the cart is empty" do
      sign_in(user)
      post users_checkout_path, params: { address: '123 Test St' }
      expect(response).to redirect_to(users_cart_path)
      follow_redirect!
      expect(response.body).to include("Your cart is empty.")
    end

    it "redirects to the cart page if address is blank" do
      sign_in(user)
      post users_checkout_path, params: { address: '' }, headers: { "HTTP_REFERER" => users_cart_path }
      expect(response).to redirect_to(users_cart_path)
      follow_redirect!
      expect(response.body).to include("Address cannot be blank.")
    end
  end

  describe "GET /search" do
    it "returns http success" do
      get users_search_path
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /search_results" do
    it "returns search results" do
      get users_search_path, params: { q: 'pizza' }
      expect(response).to have_http_status(:success)
    end

    it "redirects back with alert for empty search query" do
            get users_search_path, params: { q: '' }, headers: { "HTTP_REFERER" => root_path }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Search query cannot be blank.')
    end
  end

  describe "GET /view_all_restaurants" do
    it "returns a list of restaurants based on query" do
      get users_search_restaurant_path, params: { q: 'Test Restaurant' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /view_all_foods" do
    it "returns a list of foods based on query" do
      get users_search_food_path, params: { q: 'Test Food' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /restaurant" do
    it "shows restaurant details for valid ID" do
      restaurant = FactoryBot.create(:restaurant)
      get users_restaurant_path(restaurant.id)
      expect(response).to have_http_status(:success)
    end


    it "redirects back with notice for non-existing restaurant" do
      get users_restaurant_path(id: 99999)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Restaurant not found.')
    end
  end
end
