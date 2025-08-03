class KeylockerinfosController < ApplicationController
  def index
    @keylockerinfos = Keylockerinfo.all.paginate(page: params[:page], per_page: 9)
  end

  def show
    @info = Keylockerinfo.find(params[:id])
    #@users = @info.user  # Aqui você pode acessar o user associado ao keylockerinfo
  end
end

