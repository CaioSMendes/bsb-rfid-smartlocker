class EmailSettingsController < ApplicationController
  def new
    @email_setting = EmailSetting.order(updated_at: :desc).first_or_initialize
    @sendsms = Sendsms.order(updated_at: :desc).first_or_initialize
  end


  def create_email_setting
    @email_setting = EmailSetting.new(email_setting_params)
    puts "Parâmetros recebidos: #{email_setting_params.inspect}"
    puts "Estado do objeto EmailSetting antes de salvar: #{@email_setting.inspect}"
    if @email_setting.save
      puts "Configuração de e-mail foi salva com sucesso!"
      redirect_to new_email_setting_path, notice: 'Configuração de e-mail salva com sucesso.'
    else
      puts "Falha ao salvar configuração de e-mail. Erros: #{@email_setting.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def create_sendsms
    @sendsms = Sendsms.new(sendsms_params)
    if @sendsms.save
      flash[:notice] = "Configuração de SMS salva com sucesso!"
      redirect_to new_email_setting_path
    else
      @email_setting = EmailSetting.new # Recarrega o objeto caso o formulário falhe
      render :new
    end
  end

  def update_email_setting
    @email_setting = EmailSetting.find(params[:id])
    if @email_setting.update(email_setting_params)
      flash[:notice] = "Configuração de E-mail atualizada com sucesso!"
      redirect_to edit_email_setting_path(@email_setting)
    else
      render :edit
    end
  end

  def update_sendsms
    @sendsms = Sendsms.find(params[:sendsms][:id]) # Busca pelo ID enviado no formulário
    if @sendsms.update(sendsms_params)
      flash[:notice] = "Configuração de SMS atualizada com sucesso!"
      redirect_to new_email_setting_path
    else
      render :new
    end
  end

  def edit
    @email_setting = EmailSetting.find(params[:id])
  end
  
  def update
    @email_setting = EmailSetting.find(params[:id])
    if @email_setting.update(email_setting_params)
      redirect_to email_settings_path, notice: 'Configuração de e-mail atualizada com sucesso.'
    else
      render :edit
    end
  end
  

  private

  def email_setting_params
    params.require(:email_setting).permit(:address, :port, :tls, :user_name, :password, :authentication, :enable_starttls_auto)
  end

  def sendsms_params
    params.require(:sendsms).permit(:user, :password, :url, :hashSeguranca, :msg)
  end
end
