require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  describe 'POST /api/v2/auth/login' do
    let!(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password') }

    context 'with valid credentials' do
      it 'returns a token and success message' do
        post '/api/v2/auth/login', params: { email: 'test@example.com', password: 'password' }
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Logged in successfully')
        expect(JSON.parse(response.body)).to have_key('token')
      end
    end

    context 'with missing email or password' do
      it 'returns an error for missing email' do
        post '/api/v2/auth/login', params: { password: 'password' }
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('email is missing')
      end

      it 'returns an error for missing password' do
        post '/api/v2/auth/login', params: { email: 'test@example.com' }
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('password is missing')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized error' do
        post '/api/v2/auth/login', params: { email: 'test@example.com', password: 'wrongpassword' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /api/v2/auth/register' do
    context 'with valid registration details' do
      it 'registers the user successfully' do
        post '/api/v2/auth/register', params: {
          email: 'newuser@example.com',
          password: 'password',
          password_confirmation: 'password',
          role: 'customer'
        }
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User registered successfully')
      end
    end

    context 'with missing required fields' do
      it 'returns an error for missing email' do
        post '/api/v2/auth/register', params: {
          password: 'password',
          password_confirmation: 'password',
          role: 'customer'
        }
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('email is missing')
      end

      it 'returns an error for missing password' do
        post '/api/v2/auth/register', params: {
          email: 'newuser@example.com',
          password_confirmation: 'password',
          role: 'customer'
        }
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('password is missing')
      end
    end

    context 'with short password' do
      it 'returns an error' do
        post '/api/v2/auth/register', params: {
          email: 'newuser@example.com',
          password: 'short',
          password_confirmation: 'short',
          role: 'customer'
        }
        
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)['message']).to eq('Password is too short')
      end
    end

    context 'with password mismatch' do
      it 'returns an error' do
        post '/api/v2/auth/register', params: {
          email: 'newuser@example.com',
          password: 'password',
          password_confirmation: 'differentpassword',
          role: 'customer'
        }
        
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)['message']).to eq('Password and Password Confirmation are not the same')
      end
    end

    context 'with invalid role' do
      it 'returns an error' do
        post '/api/v2/auth/register', params: {
          email: 'newuser@example.com',
          password: 'password',
          password_confirmation: 'password',
          role: 'invalidrole'
        }
        
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)['message']).to eq('Invalid role')
      end
    end

    context 'with existing email' do
      let!(:existing_user) { FactoryBot.create(:user, email: 'existinguser@example.com', password: 'password') }

      it 'returns an error' do
        post '/api/v2/auth/register', params: {
          email: 'existinguser@example.com',
          password: 'password',
          password_confirmation: 'password',
          role: 'customer'
        }
        
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)['message']).to eq('Email already exists')
      end
    end

    context 'with invalid email' do
      it 'return validation failed' do
        post '/api/v2/auth/register', params: { 
        email: 'test',
        password: 'password',
        password_confirmation: 'password',
        role: 'customer' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Validation failed: Email is invalid')
      end
    end
  end
end
