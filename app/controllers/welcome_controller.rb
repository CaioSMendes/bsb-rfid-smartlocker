class WelcomeController < ApplicationController
  def index
    # Lockers
    @admin_lockers_count = Keylocker.count
    @user_keylockers_count = current_user.keylockers.count
    @admin_lockers_total_qtd = Keylocker.sum(:qtd)
    @user_lockers_total_qtd = current_user.keylockers.sum(:qtd)

    # Usuários e Colaboradores
    @admin_users_count = User.count
    @user_employees_count = Employee.where(user_id: current_user.id).count
    @admin_employees_count = Employee.count

    # Asset Management (Depósitos)
    @total_asset_management_count = AssetManagement.count
    @user_asset_management_count = current_user.asset_managements.count

    # Categorias
    @total_categories_count = Category.count
    @user_categories_count = Category.joins(:asset_management)
                                     .where(asset_managements: { user_id: current_user.id })
                                     .count

    # Localizações
    @total_locations_count = Location.count
    @user_locations_count = Location.joins(:asset_management)
                                    .where(asset_managements: { user_id: current_user.id })
                                    .count

    # Itens
    @total_items_count = Item.count
    @user_items_count = Item.joins(:asset_management)
                            .where(asset_managements: { user_id: current_user.id })
                            .count

    if current_user.admin?
      # Todos os itens por usuário
      @items_per_user = Item.joins(asset_management: :user)
                            .group('users.name')
                            .count
    else
      # Apenas itens do seu usuário (ou agrupar por asset_management)
      @items_per_user = Item.joins(asset_management: :user)
                            .where(asset_managements: { user_id: current_user.id })
                            .group('users.name')
                            .count
    end

    # Itens criados por mês
    if current_user.admin?
      @items_per_month = Item.group_by_month(:created_at, format: nil).count
    else
      @items_per_month = Item.joins(:asset_management)
                            .where(asset_managements: { user_id: current_user.id })
                            .group_by_month(:created_at, format: nil)
                            .count
    end

    # Converte para string no formato "Jan/2025"
    @items_per_month = @items_per_month.transform_keys { |d| d.strftime("%b/%Y") }

    if current_user.admin?
      # Conta histórico de ações por usuário
      @user_activity = HistoricManagement.joins(:user)
                                        .group('users.name')
                                        .count
    else
      # Para usuário comum, só suas próprias movimentações
      @user_activity = HistoricManagement.where(user_id: current_user.id)
                                        .group(:action)
                                        .count
    end

    @lockers_transactions_status = KeylockerTransaction.group(:status).count

    # Gráficos
    @items_per_category = Item.joins(:category)
                              .group('categories.name')
                              .count
    @lockers_per_type = Keylocker.group(:lockertype).count

    if current_user.admin?
      @items_per_location = Item.joins(:location).group('locations.name').count
    else
      @items_per_location = Item.joins(:asset_management, :location)
                                .where(asset_managements: { user_id: current_user.id })
                                .group('locations.name')
                                .count
    end
  end
end