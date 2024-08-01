require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryBot.build(:user, password: 'password', password_confirmation: 'password') }
  let(:admin) { FactoryBot.build(:user, role: 'admin', password: 'password', password_confirmation: 'password') }
  
  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    controller.instance_variable_set(:@current_user, admin)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: { email: 'newuser@example.com', password: 'password', password_confirmation: 'password', role: 'customer' }
        }.to change(User, :count).by(1)
      end

      it 'redirects to the login page' do
        post :create, params: { email: 'newuser@example.com', password: 'password', password_confirmation: 'password', role: 'customer' }
        expect(response).to redirect_to(users_login_path)
      end
    end

  end

  describe 'POST #signin' do
    # context 'with valid credentials' do
    #   it 'redirects to the appropriate path based on role' do
    #     post :signin, params: { email: user.email, password: 'password' }
    #     expect(response).to redirect_to(root_path)
    #   end
    # end

    context 'with invalid credentials' do
      it 'redirects to the login path with a notice' do
        post :signin, params: { email: user.email, password: 'wrongpassword' }
        expect(response).to redirect_to(users_login_path)
        expect(flash[:notice]).to match(/Invalid Credentials/)
      end
    end

    context 'with missing credentials' do
      it 'redirects to the login path with a notice' do
        post :signin, params: { email: '', password: '' }
        expect(response).to redirect_to(users_login_path)
        expect(flash[:notice]).to match(/Email and password must be provided/)
      end
    end
  end

  describe 'DELETE #signout' do
    it 'deletes the token cookie and redirects to login path' do
      delete :signout
      expect(response).to redirect_to(users_login_path)
    end
  end

  describe 'GET #profile' do
    context 'when user is authenticated' do
      it 'renders the profile template' do
        get :profile
        expect(response).to render_template(:profile)
      end
    end

  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the user and redirects to root path' do
        put :update, params: { user: { name: 'Updated Name', email: 'updated@example.com' } }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to match(/User details updated/)
      end
    end

  end

  describe 'DELETE #destroy' do
    it 'destroys the user and redirects to register path' do
      delete :destroy
      expect(response).to redirect_to(users_register_path)
      expect(flash[:notice]).to match(/User was successfully destroyed/)
    end
  end
end
