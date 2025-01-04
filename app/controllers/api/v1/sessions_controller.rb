# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json
    def create
      resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
      sign_in(resource_name, resource)
      render status: 200, json: { success: true, user: resource }
    end
end  