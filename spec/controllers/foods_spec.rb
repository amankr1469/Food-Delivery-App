require 'rails_helper'

RSpec.describe FoodsController, type: :controller do
  render_views
  let(:restaurant) { FactoryBot.create(:restaurant) }
  let(:food) { FactoryBot.create(:food, restaurant: restaurant) }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
  end
  
  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: food.id }
      expect(response).to be_successful
      expect(response.body).to include(food.id.to_s)
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
      get :edit, params: { id: food.id }
      expect(response).to be_successful
      expect(response.body).to include(food.id.to_s)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Food' do
        expect {
          post :create, params: { food: FactoryBot.attributes_for(:food, restaurant_id: restaurant.id) }
        }.to change(Food, :count).by(1)
      end

      it 'redirects to the created food' do
        post :create, params: { food: FactoryBot.attributes_for(:food, restaurant_id: restaurant.id) }
        expect(response).to redirect_to(Food.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Food' do
        expect {
          post :create, params: { food: FactoryBot.attributes_for(:food, name: nil) }
        }.to change(Food, :count).by(0)
      end

      it 'renders the new template' do
        post :create, params: { food: FactoryBot.attributes_for(:food, name: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: 'Updated Food Name' }
      }

      it 'updates the requested food' do
        put :update, params: { id: food.id, food: new_attributes }
        food.reload
        expect(food.name).to eq('Updated Food Name')
      end

      it 'redirects to the food' do
        put :update, params: { id: food.id, food: new_attributes }
        expect(response).to redirect_to(food)
      end
    end

    context 'with invalid params' do
      it 'does not update the food' do
        put :update, params: { id: food.id, food: { name: nil } }
        food.reload
        expect(food.name).not_to eq(nil)
      end

      it 'renders the edit template' do
        put :update, params: { id: food.id, food: { name: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested food' do
      food
      expect {
        delete :destroy, params: { id: food.id }
      }.to change(Food, :count).by(-1)
    end

    it 'redirects to the restaurant' do
      delete :destroy, params: { id: food.id }
      expect(response).to redirect_to(restaurants_url)
    end
  end
end
