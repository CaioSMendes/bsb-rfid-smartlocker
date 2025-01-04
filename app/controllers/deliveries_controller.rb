class DeliveriesController < ApplicationController
    def new
      @delivery = Delivery.new
      @deliverers = Deliverer.all
      @employees = Employee.all
    end
  
    def create
      @delivery = Delivery.new(delivery_params)
      if @delivery.save
        flash[:notice] = "Encomenda criada com sucesso!"
        redirect_to deliveries_path
      else
        flash[:alert] = "Erro ao criar encomenda."
        render :new
      end
    end
  
    private
  
    def delivery_params
      params.require(:delivery).permit(:package_description, :deliverer_id, :employee_id, :delivery_date, :locker_code)
    end
end 
