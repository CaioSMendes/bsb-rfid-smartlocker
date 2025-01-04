# app/controllers/api/v1/keylockers_controller.rb
module Api
    module V1
      class KeylockersController < ApplicationController
        before_action :set_keylocker, only: [:show]
        skip_before_action :verify_authenticity_token, only: [:index, :new, :create, :update, :show]
        skip_before_action :authenticate_user!, only: [:index, :new, :create, :update, :show]
        protect_from_forgery with: :null_session

        # GET /keylockers or /keylockers.json
        def index
          @keylockers = Keylocker.all
          render json: @keylockers
        end


        # GET /keylockers/new
        def new
          @keylocker = Keylocker.new
        end

        # GET /keylockers/1 or /keylockers/1.json
        def show
          render json: @keylocker.as_json(only: [:id, :owner, :nameDevice, :ipAddress, :status])
        end

      
        # POST /keylockers or /keylockers.json
        def create
          @keylocker = Keylocker.new(keylocker_params)
        
          respond_to do |format|
            if @keylocker.save
              format.json { render json: { message: "Keylocker was successfully created.", keylocker: @keylocker }, status: :created, location: @keylocker }
            else
              format.json { render json: @keylocker.errors, status: :unprocessable_entity }
            end
          end
        end

        # PATCH/PUT /api/v1/keylockers/1
        def update
          if @keylocker.update(key_locker_params)
            render json: @keylocker
          else
            render json: @keylocker.errors, status: :unprocessable_entity
          end
        end

        
        # DELETE /api/v1/keylockers/1
        def destroy
          @keylocker.destroy
          head :no_content
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_keylocker
            @keylocker = Keylocker.find(params[:id])
          end

          # Only allow a list of trusted parameters through.
          def keylocker_params
            params.require(:keylocker).permit(:owner, :nameDevice, :ipAddress, :status)
          end
      end
    end
  end
  