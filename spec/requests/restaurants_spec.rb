require 'rails_helper'

RSpec.describe RestaurantsController, type: :controller do
  let(:user) { FactoryBot.create(:user, role: 'admin') }
  let(:admin) { FactoryBot.create(:user, role: 'admin') }
  let(:restaurant) { FactoryBot.create(:restaurant, user: admin) }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(controller).to receive(:set_user).and_return(true)
    controller.instance_variable_set(:@current_user, admin)
    controller.instance_variable_set(:@user, admin)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: restaurant.id }
      expect(response).to be_successful
    end

    it 'redirects to index with a notice if restaurant does not exist' do
      get :show, params: { id: -1 }
      expect(response).to redirect_to(restaurants_url)
      expect(flash[:notice]).to eq("Restaurant not found.")
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: restaurant.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new restaurant' do
        expect {
          post :create, params: { restaurant: FactoryBot.attributes_for(:restaurant) }
          puts "Response body: #{response.body}"
          puts "Response status: #{response.status}"
        }.to change(Restaurant, :count).by(1)
      end

      it 'redirects to the created restaurant' do
        post :create, params: { restaurant: FactoryBot.attributes_for(:restaurant) }
        expect(response).to redirect_to(Restaurant.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a new restaurant' do
        expect {
          post :create, params: { restaurant: FactoryBot.attributes_for(:restaurant, name: nil) }
        }.to change(Restaurant, :count).by(0)
      end

      it 'renders the new template' do
        post :create, params: { restaurant: FactoryBot.attributes_for(:restaurant, name: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: "Updated Restaurant" }
      }

      it 'updates the requested restaurant' do
        put :update, params: { id: restaurant.id, restaurant: new_attributes }
        restaurant.reload
        expect(restaurant.name).to eq("Updated Restaurant")
      end

      it 'redirects to the restaurant' do
        put :update, params: { id: restaurant.id, restaurant: new_attributes }
        expect(response).to redirect_to(restaurant)
      end
    end

    context 'with invalid params' do
      it 'does not update the restaurant' do
        put :update, params: { id: restaurant.id, restaurant: { name: nil } }
        restaurant.reload
        expect(restaurant.name).not_to eq(nil)
      end

      it 'renders the edit template' do
        put :update, params: { id: restaurant.id, restaurant: { name: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested restaurant' do
      restaurant
      expect {
        delete :destroy, params: { id: restaurant.id }
      }.to change(Restaurant, :count).by(-1)
    end

    it 'redirects to the restaurants list' do
      delete :destroy, params: { id: restaurant.id }
      expect(response).to redirect_to(restaurants_url)
    end
  end
end
