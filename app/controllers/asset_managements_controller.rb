class AssetManagementsController < ApplicationController
  before_action :authenticate_user!  # só usuários logados
  before_action :set_asset_management, only: %i[ show edit update destroy ]

  # GET /asset_managements or /asset_managements.json
  def index
    @asset_managements = current_user.asset_managements.order(:id).paginate(page: params[:page], per_page: 10)
  end

  # GET /asset_managements/1 or /asset_managements/1.json
  def show
    @latest_locations  = @asset_management.locations.order(created_at: :desc).limit(4)
    @latest_categories = @asset_management.categories.order(created_at: :desc).limit(4)
    @latest_items      = @asset_management.items.order(created_at: :desc).limit(4)
  end

  # GET /asset_managements/new
  def new
    @asset_management = current_user.asset_managements.build
  end

  # GET /asset_managements/1/edit
  def edit
  end

  # POST /asset_managements or /asset_managements.json
  def create
    @asset_management = current_user.asset_managements.build(asset_management_params)
    if @asset_management.save
      redirect_to @asset_management, notice: "Depósito criado com sucesso!"
    else
      render :new
    end
  end

  # PATCH/PUT /asset_managements/1 or /asset_managements/1.json
  def update
    respond_to do |format|
      if @asset_management.update(asset_management_params)
        format.html { redirect_to asset_management_url(@asset_management), notice: "Asset management was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_management }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_management.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_managements/1 or /asset_managements/1.json
  def destroy
    @asset_management.destroy

    respond_to do |format|
      format.html { redirect_to asset_managements_url, notice: "Asset management was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_asset_management
    @asset_management = current_user.asset_managements.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to asset_managements_path, alert: "Você não tem acesso a este depósito"
  end

    # Only allow a list of trusted parameters through.
    def asset_management_params
      params.require(:asset_management).permit(:name, :description, :serial)
    end
end
