class ItemsController < ApplicationController
  before_action :set_asset_management
  before_action :set_item, only: %i[show edit update destroy]
  before_action :load_lookup_data, only: %i[new create edit update]

  # GET /items or /items.json
  def index
    @items = @asset_management.items
                              .includes(:category, :location)
                              .paginate(page: params[:page], per_page: 10)
  end

  # GET /items/1 or /items/1.json
  def show
    @item = Item.find(params[:id])
    
    HistoricManagement.create(
      item: @item,
      user: current_user,
      action: "view",
      description: "Item visualizado",
      action_time: Time.current
    )
  end

  # GET /items/new
  def new
    @item = @asset_management.items.build
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items or /items.json
  def create
    @item = @asset_management.items.build(item_params)
    if @item.save
      redirect_to asset_management_item_path(@asset_management, @item), notice: "Item criado."
    else
      render :new
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    @item = current_user.asset_managements.find(params[:asset_management_id]).items.find(params[:id])

    if @item.update(item_params)
      # Cria histórico
      HistoricManagement.create(
        item: @item,
        user: current_user,        # <-- use current_user aqui
        action: "Edição",
        description: "Item atualizado",
        action_time: Time.current
      )

      redirect_to asset_management_item_path(@item.asset_management, @item), notice: "Item atualizado com sucesso."
    else
      render :edit
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    @item.destroy
    redirect_to asset_management_items_path(@asset_management), notice: "Item removido."
  end

  private
    def set_asset_management
      @asset_management = AssetManagement.find(params[:asset_management_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @asset_management.items.find(params[:id])
    end

    def load_lookup_data
      @categories = @asset_management.categories
      @locations = @asset_management.locations
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:asset_management_id, :category_id, :location_id, :name, :tagRFID, :idInterno, :description, :image, :status, :empty)
    end
end
