class AssetManagementsController < ApplicationController
  before_action :authenticate_user!  # só usuários logados
  before_action :set_asset_management, only: %i[ show edit update destroy ] 
  before_action :check_asset_management_status

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

  def export_excel
    @asset_managements = current_user.asset_managements.includes(:items, :categories, :locations)

    respond_to do |format|
      format.xlsx {
        xlsx_package = Axlsx::Package.new
        wb = xlsx_package.workbook

        wb.add_worksheet(name: "Depósitos e Itens") do |sheet|
          # Cabeçalho
          sheet.add_row ["Depósito", "Serial", "Descrição do Depósito", "Item", "Categoria", "Local", "Tag RFID", "ID Interno", "Descrição Item", "Status", "Disponível"]

          # Percorre todos os depósitos e itens
          @asset_managements.each do |deposito|
            deposito.items.each do |item|
              sheet.add_row [
                deposito.name,
                deposito.serial,
                deposito.description,
                item.name,
                item.category&.name,
                item.location&.name,
                item.tagRFID,
                item.idInterno,
                item.description,
                item.status,
                item.empty == 0 ? "Sim" : "Não"
              ]
            end
          end
        end

        # Envia o arquivo
        send_data xlsx_package.to_stream.read,
                  filename: "relatorio_depositos.xlsx",
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      }
    end
  end

  private
  def check_asset_management_status
    unless current_user.assetManagement?
      flash[:alert] = "Você não tem permissão para acessar esta seção."
      redirect_to root_path # ou outra página segura
    end
  end
  
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
