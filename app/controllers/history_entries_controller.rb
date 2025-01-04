# app/controllers/history_entries_controller.rb
class HistoryEntriesController < ApplicationController
    before_action :set_history_entry, only: [:show, :edit, :update, :destroy]
  
    def index
      user_id = current_user.id
      puts "User ID: #{user_id}"
    
      @employee = Employee.find_by(user_id: user_id)
    
      if @employee
        puts "Employee found: #{@employee.inspect}"
    
        # Recupera os keylockers associados ao empregado
        @keylockers = @employee.keylockers
        @keylockers.each do |keylocker|
          puts "Keylocker Serial: #{keylocker.serial}"
        end
    
        # Filtra KeyUsage pelo serial dos keylockers associados ao empregado
        @key_usages = KeyUsage.joins(:keylocker)
                              .where(keylockers: { serial: @keylockers.pluck(:serial) })
                              .paginate(page: params[:page], per_page: 10)
        
        puts "Key Usages Count: #{@key_usages.count}"
        puts "Key Usages: #{@key_usages.inspect}"
    
        if @key_usages.any?
          @keylocker_serial = @key_usages.first.keylocker.serial
          puts "Keylocker Serial: #{@keylocker_serial}"
        else
          @keylocker_serial = 'Não disponível'
        end
      else
        puts "No employee found for User ID: #{user_id}"
        @key_usages = KeyUsage.none.paginate(page: params[:page], per_page: 10)
        @keylocker_serial = 'Não disponível'
      end
    end
    
    
    

    def indexLD
      @key_usages = KeyUsage.all.paginate(page: params[:page], per_page: 10)
    end
  

    def show
    end
  
    def new
      @history_entry = HistoryEntry.new
    end
  
    def create
      history_entry_params = params.require(:history_entry).permit(:owner, :name_device, :employee_info, :keys_taken, :keys_returned, :sequence_order, :datahistory)
      #@key_usages = HistoryEntry.new(history_entry_params)
  
      if @history_entry.save
        redirect_to @history_entry, notice: 'History entry was successfully created.'
      else
        render :new
      end
    end
  
    def edit
    end
  
    def update
      if @history_entry.update(history_entry_params)
        redirect_to @history_entry, notice: 'History entry was successfully updated.'
      else
        render :edit
      end
    end
  
    def destroy
        @history_entry = HistoryEntry.find(params[:id])
        @history_entry.destroy
        redirect_to history_entries_path, notice: 'History entry was successfully destroyed.'
    end
  
    private
  
    def set_history_entry
      @history_entry = HistoryEntry.find(params[:id])
    end
  
    def history_entry_params
      params.require(:history_entry).permit(:owner, :name_device, :employee_info, :keys_taken, :keys_returned, :sequence_order, :datahistory)
    end
  end  