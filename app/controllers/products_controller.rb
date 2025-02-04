class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params[:id])
    @serial = params[:serial]  # Acessando o parâmetro 'serial'
  end

  # GET /products/new
  def new
    @serial = params[:serial] # Captura o serial da URL
    Rails.logger.debug "Serial recebido: #{@serial}" # Depuração
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  def create
    @serial = params[:serial] # Captura o serial da URL
    serial = params[:serial] # Obtém o serial dos parâmetros
    @product = Product.new(product_params)
  
    # Anexando as imagens antes de salvar o produto
    if params[:product][:imageEntregador].present?
      @product.image_entregador.attach(params[:product][:imageEntregador])
    end
  
    if params[:product][:imageInvoice].present?
      @product.image_invoice.attach(params[:product][:imageInvoice])
    end
  
    if params[:product][:imageProduct].present?
      @product.image_product.attach(params[:product][:imageProduct])
    end
  
    respond_to do |format|
      if @product.save
        # Redirecionando após o produto e as imagens serem salvos
        puts "Serial recebido: #{params[:serial]}"
        format.html { redirect_to product_path(@product, serial: params[:serial]), notice: "Produto foi criado com sucesso." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def save_serial
    @product = Product.create(serial: params[:serial]) # Cria um novo produto com o serial
    if @product.persisted?
      render json: { success: true, product_id: @product.id }
    else
      render json: { success: false, errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:serial, :package_description, :locker_code, :pin, :full_address)
      #params.require(:product).permit(:package_description, :locker_code, :pin, :full_address, :imageEntregador, :imageInvoice, :imageProduct)
    end
end
