class ItemsController < ApplicationController
  before_action :set_asset_management
  before_action :set_item, only: %i[show edit update destroy] # export_excel NÃO entra aqui
  before_action :load_lookup_data, only: %i[new create edit update]
  before_action :check_asset_management_status

  # GET /asset_managements/:asset_management_id/items
  def index
    @items = @asset_management.items
                              .includes(:category, :location)
                              .paginate(page: params[:page], per_page: 10)
  end

  # GET /asset_managements/:asset_management_id/items/:id
  def show
    HistoricManagement.create(
      item: @item,
      user: current_user,
      action: "view",
      description: "Item visualizado",
      action_time: Time.current
    )
  end

  # GET /asset_managements/:asset_management_id/items/new
  def new
    @item = @asset_management.items.build
  end

  # GET /asset_managements/:asset_management_id/items/:id/edit
  def edit
  end

  # POST /asset_managements/:asset_management_id/items
  def numeric?(string)
    true if Integer(string) rescue false
  end

  def create
    assign_category_from_text
    @item = @asset_management.items.build(item_params.except(:category_name))

    # Força category_id se estiver definido
    if params[:item][:category_id].present?
      @item.category_id = params[:item][:category_id]
    end

    if @item.save
      HistoricManagement.create(
        item: @item,
        user: current_user,
        action: "Criação",
        description: "Item criado",
        action_time: Time.current
      )
      redirect_to [@asset_management, @item], notice: "Ativo criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /asset_managements/:asset_management_id/items/:id
  def update
    handle_dynamic_location_and_category

    # Atualiza os outros atributos
    if @item.update(item_params)
      # Cria histórico
      HistoricManagement.create(
        item: @item,
        user: current_user,
        action: "Edição",
        description: "Item atualizado",
        action_time: Time.current
      )

      redirect_to asset_management_item_path(@asset_management, @item), notice: "Item atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /asset_managements/:asset_management_id/items/:id
  def destroy
    @item.destroy
    redirect_to asset_management_items_path(@asset_management), notice: "Item removido."
  end

  # GET /asset_managements/:asset_management_id/items/export_excel
  def export_excel
    Rails.logger.debug "Entrou no export_excel"
    @items = @asset_management.items.includes(:category, :location)
    Rails.logger.debug "Itens carregados: #{@items.count}"

    respond_to do |format|
      format.xlsx do
        Rails.logger.debug "Gerando Excel"
        response.headers['Content-Disposition'] =
          "attachment; filename=itens_deposito_#{@asset_management.name.parameterize}.xlsx"
      end
    end
  end

  private

  def assign_category_from_text
    if params[:item][:category_name].present?
      category = @asset_management.categories.find_or_create_by!(name: params[:item][:category_name]) do |c|
        c.user_id = current_user.id  # se for obrigatório
        c.description = ""            # se necessário
      end

      params[:item][:category_id] = category.id
      puts "category_id atribuído: #{category.id}"
    end
  end

  def check_asset_management_status
    unless current_user.assetManagement?
      flash[:alert] = "Você não tem permissão para acessar esta seção."
      redirect_to root_path # ou outra página segura
    end
  end

  def set_asset_management
    @asset_management = current_user.asset_managements.find(params[:asset_management_id])
  end

  def set_item
    @item = @asset_management.items.find(params[:id])
  end

  def load_lookup_data
    @categories = @asset_management.categories
    @locations = @asset_management.locations
  end

  def item_params
    params.require(:item).permit(:category_id, :category_name, :location_id, :name, :qtdDigito, :tagRFID, :idInterno, :description, :image, :status, :empty)
  end

  def handle_dynamic_location_and_category
    # Localização
    if params[:item][:location_id].present? && !numeric?(params[:item][:location_id])
      location_name = params[:item][:location_id]
      location = @asset_management.locations.find_or_create_by(name: location_name)
      params[:item][:location_id] = location.id
    end

    # Categoria
    if params[:item][:category_id].present? && !numeric?(params[:item][:category_id])
      category_name = params[:item][:category_id]
      category = @asset_management.categories.find_or_create_by(name: category_name)
      params[:item][:category_id] = category.id
    end
  end
end