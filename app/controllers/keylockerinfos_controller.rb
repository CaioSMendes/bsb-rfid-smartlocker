class KeylockerinfosController < ApplicationController
    before_action :set_keylockerinfo, only: [:show, :edit, :update, :destroy]

 
  def index
    if current_user.admin?
      @keylockers = Keylocker.all.paginate(page: params[:page], per_page: 12)
    else
      @keylockers = current_user.keylockers.paginate(page: params[:page], per_page: 12)
    end
  end

  def show
    @info = Keylockerinfo.find(params[:id])
  end

  def create
    @keylockerinfo = Keylockerinfo.new(keylockerinfo_params)

    if @keylockerinfo.save
      redirect_to @keylockerinfo, notice: 'Keylockerinfo was successfully created.'
    else
      render :new
    end
  end

  def update
    if @keylockerinfo.update(keylockerinfo_params)
      redirect_to @keylockerinfo, notice: 'Keylockerinfo was successfully updated.'
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_keylockerinfo
    @keylockerinfo = Keylockerinfo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def keylockerinfo_params
    params.require(:keylockerinfo).permit(
      :object, 
      :posicion, 
      :tagRFID, 
      :idInterno, 
      :description, 
      :empty, 
      :keylocker_id,
      image: [], # Para permitir a imagem ser carregada como um arquivo
      keylockerinfos_attributes: [:object, :posicion, :tagRFID, :idInterno, :description, :empty, :image] # Adiciona a imagem aqui também
    )
  end
end

