class KeylockersController < ApplicationController
  before_action :set_keylocker, only: %i[ show edit update destroy ]

  #before_action :authenticate_admin_user! # Certifique-se de ter um método de autenticação de admin
  skip_before_action :verify_authenticity_token, only: [:toggle_and_save_status, :update]
  skip_before_action :authenticate_user!, only: [:toggle_and_save_status]

  # GET /keylockers or /keylockers.json
  def index
    if current_user.admin?
      @keylockers = Keylocker.all.paginate(page: params[:page], per_page: 9)
    else
      @keylockers = current_user.keylockers.paginate(page: params[:page], per_page: 9)
    end
  end

  # GET /keylockers/1 or /keylockers/1.json
  def show
    @keylocker = Keylocker.find(params[:id]) # Busca o Keylocker pelo ID
    @users = @keylocker.users
  end

  # GET /keylockers/new
  def new
    @keylocker = Keylocker.new
  end

  # GET /keylockers/1/edit
  def edit
    @keylocker = Keylocker.find(params[:id])
  end

  # POST /keylockers or /keylockers.json
  def create
    @keylocker = Keylocker.new(keylocker_params)

    respond_to do |format|
      if @keylocker.save
        format.html { redirect_to keylocker_url(@keylocker), notice: "O Keylocker foi criado com sucesso." }
        format.json { render :show, status: :created, location: @keylocker }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @keylocker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keylockers/1 or /keylockers/1.json
def update
  logger.debug "Params: #{params.inspect}"  # Adicione isso para ver os parâmetros
  respond_to do |format|
    if @keylocker.update(keylocker_params)
      format.html { redirect_to keylocker_url(@keylocker), notice: "O Keylocker foi editado." }
      format.json { render :show, status: :ok, location: @keylocker }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @keylocker.errors, status: :unprocessable_entity }
    end
  end
end


  def keylockerinfos_reload
    @keylocker = Keylocker.find(params[:id])
    render layout: false  # Só renderiza o frame mesmo
  end

  # DELETE /keylockers/1 or /keylockers/1.json
  def destroy
    @keylocker.destroy

    respond_to do |format|
      format.html { redirect_to keylockers_url, notice: "O Keylocker foi deletado com sucesso." }
      format.json { head :no_content }
    end
  end

  def assign_keylocker
    user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])
    #user.assign_keylocker(keylocker)
    user.keylockers << keylocker
    redirect_to users_path, notice: 'Locker atribuído com sucesso!'
  end

  def remove_keylocker
    #user_locker = UserLocker.find_by(user_id: params[:user_id], keylocker_id: @keylocker.id)
    #user_locker.destroy if user_locker.present?
    user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])
    user.remove_keylocker(keylocker)
    redirect_to users_path, notice: 'Locker removido com sucesso!'
  end

  def toggle_and_save_status
    @keylocker = Keylocker.find(params[:id])
    @keylocker.toggle_and_save_status! # Supondo que você tenha um método correspondente no modelo

    respond_to do |format|
      format.json { render json: { status: @keylocker.status } }
    end
  end

  def generate_qr
    keylocker = Keylocker.find(params[:id]) # Busca o armário pelo ID
    serial = keylocker.serial
    qr_url = "#{request.base_url}/access_auth?serial=#{serial}"

    qr_code = RQRCode::QRCode.new(qr_url)

    render inline: qr_code.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
  end

  def generate_qr_delivery
    keylocker = Keylocker.find(params[:id])
    serial = keylocker.serial
    qr_data = "#{request.base_url}/deliverers/check?serial=#{serial}"
    qrcode = RQRCode::QRCode.new(qr_data)
    svg = qrcode.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true
    )
    render inline: svg, content_type: "image/svg+xml"
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keylocker
      @keylocker = Keylocker.find(params[:id])
    end

    def authenticate_admin_user!
      # Adicione lógica para verificar se o usuário é um administrador.
      # Você pode usar Devise's current_user ou outra lógica personalizada.
    end

    def keylocker_params
      params.require(:keylocker).permit(
        :owner, :nameDevice, :cnpjCpf, :qtd, :serial, :lockertype, :status, 
        keylockerinfos_attributes: [
          :id, :object, :posicion, :tagRFID, :idInterno, :description, :_destroy
        ]
      )
    end
end

