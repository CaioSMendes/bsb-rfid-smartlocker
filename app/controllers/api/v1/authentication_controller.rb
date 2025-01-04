# app/controllers/api/v1/authentication_controller.rb
class Api::V1::AuthenticationController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def sign_in
      user = User.find_by(email: params[:email])
  
      if user&.valid_password?(params[:password])
        render json: { token: user.authentication_token }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  end
  