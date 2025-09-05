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
    @keylocker = @info.keylocker  # Assumindo que Keylockerinfo pertence a Keylocker
  end

  def create
    @keylockerinfo = Keylockerinfo.new(keylockerinfo_params)

    if @keylockerinfo.save
      redirect_to @keylockerinfo, notice: 'Keylockerinfo was successfully created.'
    else
      render :new
    end
  end

  def edit
    # O Rails já vai usar o `set_keylockerinfo` para carregar o objeto correto.
  end

  # DELETE /keylockers/:keylocker_id/keylockerinfos/:id
  def destroy
    # Adicionando um log para verificar se o Keylockerinfo foi encontrado
    Rails.logger.debug "Excluindo KeylockerInfo com ID: #{params[:id]}"
    
    # Verificando se o Keylockerinfo foi encontrado e está sendo destruído
    if @keylockerinfo.destroy
      Rails.logger.debug "KeylockerInfo com ID #{params[:id]} foi excluído com sucesso!"
      redirect_to keylockerinfos_path, notice: "O Keylocker Info foi deletado com sucesso."
    else
      Rails.logger.debug "Falha ao excluir o KeylockerInfo com ID: #{params[:id]}"
      redirect_to keylockerinfos_path, alert: "Falha ao excluir o Keylocker Info."
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
      :image,
      keylockerinfos_attributes: [:object, :posicion, :tagRFID, :idInterno, :description, :empty, :image] # Adiciona a imagem aqui também
    )
  end
end

