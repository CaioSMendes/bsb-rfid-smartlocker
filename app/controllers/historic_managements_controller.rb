class HistoricManagementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset_management
  before_action :set_item

  def index
    # Pega os últimos 5 históricos, ordenados da mais recente
    @historic_managements = @item.historic_managements.includes(:user).order(action_time: :desc).limit(5)
  end

  def show
    @historic_management = @item.historic_managements.find(params[:id])
  end

  private

  def set_asset_management
    # Pega apenas o asset_management do usuário logado
    @asset_management = current_user.asset_managements.find(params[:asset_management_id])
  end

  def set_item
    @item = @asset_management.items.find(params[:item_id])
  end
end