class LocationsController < ApplicationController
  before_action :set_asset_management
  before_action :set_location, only: %i[ show edit update destroy ]
  before_action :check_asset_management_status

  # GET /locations or /locations.json
  def index
    if params[:asset_management_id]
      @asset_management = AssetManagement.find(params[:asset_management_id])
      @locations = @asset_management.locations.order(:id).paginate(page: params[:page], per_page: 10)
    else
      @asset_management = current_user.asset_managements.first
      @locations = @asset_management ? @asset_management.locations.order(:id).paginate(page: params[:page], per_page: 10) : []
    end
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = @asset_management.locations.build
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    @location = Location.new(location_params)
    @location.user = current_user  # <--- garante que o usuário seja associado

    if @location.save
      redirect_to locations_path, notice: 'Location criada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    if @location.update(location_params)
      redirect_to asset_management_location_path(@asset_management, @location), notice: "Localização atualizada."
    else
      render :edit
    end
  end

  # DELETE /locations/1 or /locations/1.json
   def destroy
    @location.destroy
    redirect_to asset_management_locations_path(@asset_management), notice: "Localização removida."
  end

  private

    def check_asset_management_status
      unless current_user.assetManagement?
        flash[:alert] = "Você não tem permissão para acessar esta seção."
        redirect_to root_path # ou outra página segura
      end
    end
    
    def set_asset_management
      @asset_management = AssetManagement.find(params[:asset_management_id]) if params[:asset_management_id].present?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = if @asset_management
                    @asset_management.locations.find(params[:id])
                  else
                    Location.find(params[:id])
                  end
    end

    # Only allow a list of trusted parameters through.
    def location_params
      params.require(:location).permit(:name, :code, :address, :description, :asset_management_id)
    end
end
