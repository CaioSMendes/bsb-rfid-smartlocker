class CategoriesController < ApplicationController
  before_action :set_asset_management, only: %i[show edit update destroy new create]
  before_action :set_category, only: %i[show edit update destroy]


  # GET /asset_managements/:asset_management_id/categories 
  def index
    if params[:asset_management_id]
      # Apenas categorias do depósito selecionado
      @asset_management = AssetManagement.find(params[:asset_management_id])
      @categories = @asset_management.categories.order(:id).paginate(page: params[:page], per_page: 10)
    else
      # Se não veio nenhum depósito, pega o primeiro do usuário (ou nenhum)
      @asset_management = current_user.asset_managements.first
      @categories = @asset_management ? @asset_management.categories.order(:id).paginate(page: params[:page], per_page: 10) : []
    end
  end

  # GET /asset_managements/:asset_management_id/categories/:id
  def show
  end

  # GET /asset_managements/:asset_management_id/categories/new
  def new
    @category = @asset_management.categories.build
  end

  # GET /asset_managements/:asset_management_id/categories/:id/edit
  def edit
  end

  # POST /asset_managements/:asset_management_id/categories
  def create
    @category = Category.new(category_params)
    @category.user = current_user
    @category.asset_management = current_user.asset_managements.first # garante que tem um depósito inicial

    if @category.save
      redirect_to categories_path, notice: 'Categoria criada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /asset_managements/:asset_management_id/categories/:id
  def update
    if @category.update(category_params)
      redirect_to asset_management_category_path(@asset_management, @category), notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /asset_managements/:asset_management_id/categories/:id
  def destroy
    @category.destroy
    redirect_to asset_management_categories_path(@asset_management), notice: "Category was successfully destroyed."
  end

  private

  def set_asset_management
    @asset_management = AssetManagement.find(params[:asset_management_id])
  end

  def set_category
    @category = @asset_management.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end