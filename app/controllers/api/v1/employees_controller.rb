I18n.locale = :pt

module Api
  module V1
    class EmployeesController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:check_access, :control_locker_key, :control_exit_keypad, :control_exit_card, :locker_security, :toggle_door, :employees_by_keylocker, :process_locker_code, :check_card_access, :check_keypad_access, :employees_by_keylocker_card,:information_locker, :esp8288params, :check_user]
      skip_before_action :authenticate_user!, only: [:check_access, :control_locker_key, :control_exit_keypad, :control_exit_card, :locker_security, :toggle_door, :employees_by_keylocker, :process_locker_code, :check_card_access, :check_keypad_access, :employees_by_keylocker_card, :information_locker, :esp8288params, :check_user ]

      # Define a localização padrão como português do Brasil
      before_action :set_locale

      def index
        @employees = Employee.all
        render json: @employees
      end

      def toggle_door
        keylocker = Keylocker.find_by(serial: params[:serial])
      
        if keylocker.present?
          keylocker.door = "aberto"
          
          if keylocker.save
            # Envia para um job em segundo plano
            ToggleDoorJob.perform_later(keylocker.id)
            
            render json: { message: "Porta #{keylocker.door} por 10 segundos", status: :ok }
          else
            render json: { error: keylocker.errors.full_messages, status: :unprocessable_entity }
          end
        else
          render json: { error: "Keylocker não encontrado", status: :not_found }
        end
      end

      def control_locker_key
        # Recebe os parâmetros do JSON
        serial = params[:serial]
        locker_codes = params[:keys]
        senha = params[:senha] # Adiciona a senha para consultar o employee
        
        # Valida e processa 'keys'
        if locker_codes.present?
          locker_codes = locker_codes.strip.gsub("\n", "").gsub('LS ', '') # Limpa os códigos
      
          if locker_codes.empty?
            return render json: { error: "Código do locker não pode ser vazio." }, status: :bad_request
          end
        else
          return render json: { error: "'keys' não está presente nos parâmetros." }, status: :bad_request
        end
      
        # Encontra o keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
        unless keylocker
          return render json: { error: "Keylocker não encontrado." }, status: :not_found
        end
      
        # Verifica o número de nichos
        expected_count = keylocker.keylockerinfos.count
        if expected_count != locker_codes.length
          return render json: { error: "Número de nichos não corresponde ao código fornecido." }, status: :unprocessable_entity
        end
      
        # Consulta o employee pela senha ou cartão RFID
        employee = Employee.find_by(pswdSmartlocker: senha) || Employee.find_by(cardRFID: senha)
        unless employee
          return render json: { error: "Funcionário não encontrado." }, status: :not_found
        end
      
        # Processa alterações e registra no log
        changes_log = []
        locker_codes.chars.each_with_index do |new_state_char, index|
          position = index + 1
          keylocker_info = keylocker.keylockerinfos.find_by(posicion: position)
          next unless keylocker_info
      
          old_state = keylocker_info.empty
          new_state = new_state_char.to_i
      
          # Verifica mudanças
          if old_state != new_state
            # Atualiza o estado
            keylocker_info.update(empty: new_state)
      
            action = nil
            if old_state == 0 && new_state == 1
              action = "devolução"
              changes_log << { position: position, action: action }
            elsif old_state == 1 && new_state == 0
              action = "retirada"
              changes_log << { position: position, action: action }
            end
      
            # Salva o log com os comentários da posição e o funcionário associado
            Log.create!(
              employee_id: employee.id,
              action: (old_state == 1 && new_state == 0) ? "retirada" : "devolução",
              key_id: keylocker.serial,
              locker_name: keylocker.nameDevice,
              timestamp: Time.now,
              status: (new_state == 1) ? "Ocupado" : "Disponível",
              comments: "Chave #{position} registro de #{action} por #{employee.email}"
            )
          end
        end
      
        # Retorna o resultado
        if changes_log.any?
          render json: { 
            status: "SUCCESS", 
            message: "Alterações registradas com sucesso.", 
            changes_log: changes_log 
          }, status: :ok
        else
          render json: { 
            status: "SUCCESS", 
            message: "Nenhuma alteração foi realizada." 
          }, status: :ok
        end
      end      

      def control_exit_card
        # Parse do payload recebido
        serial = params[:serial]
        snh_card_usr = params[:card]
        flag = params[:flag]
      
        # Validação dos parâmetros
        if serial.blank? || snh_card_usr.blank? || !["1", "2"].include?(flag)
          render json: { error: "Parâmetros inválidos" }, status: :unprocessable_entity
          return
        end
      
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
      
        unless keylocker
          render json: { error: "Keylocker não encontrado" }, status: :not_found
          return
        end
      
        # Encontra o Employee pelo cardRFID
        employee = Employee.find_by(cardRFID: snh_card_usr)
      
        unless employee
          render json: { error: "Funcionário não encontrado pelo cartão RFID" }, status: :not_found
          return
        end
      
        # Definir a ação com base na flag
        action = flag == "1" ? "entrada" : "saida"
      
        # Verificar o status atual do Keylocker
        last_log = Log.where(key_id: keylocker.serial).order(timestamp: :desc).first
      
        if action == "entrada" && last_log&.status == "Ocupado"
          render json: { error: "Ação inválida: o Keylocker já está ocupado" }, status: :unprocessable_entity
          return
        elsif action == "saida" && (!last_log || last_log.status == "Disponível")
          render json: { error: "Ação inválida: o Keylocker já está disponível" }, status: :unprocessable_entity
          return
        end
      
        # Salvar o log
        log = Log.new(
          employee_id: employee.id,
          action: action,
          key_id: keylocker.serial,
          locker_name: keylocker.nameDevice,
          timestamp: Time.now,
          status: action == "entrada" ? "Ocupado" : "Disponível",
          comments: "Nicho associado ao funcionário #{employee.email}"
        )
      
        if log.save
          render json: { message: "Ação registrada com sucesso", log: log }, status: :ok
        else
          render json: { error: "Erro ao salvar o log", details: log.errors.full_messages }, status: :internal_server_error
        end
      end
      
      

      def control_exit_keypad
        # Parse do payload recebido
        serial = params[:serial]
        snh_keypad_usr = params[:keypad]
        flag = params[:flag]
      
        # Validação dos parâmetros
        if serial.blank? || snh_keypad_usr.blank? || !["1", "2"].include?(flag)
          render json: { error: "Parâmetros inválidos" }, status: :unprocessable_entity
          return
        end
      
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
      
        unless keylocker
          render json: { error: "Keylocker não encontrado" }, status: :not_found
          return
        end
      
        # Encontra o Employee pelo pswdSmartlocker
        employee = Employee.find_by(pswdSmartlocker: snh_keypad_usr)
      
        unless employee
          render json: { error: "Funcionário não encontrado pela senha do teclado" }, status: :not_found
          return
        end
      
        # Definir a ação com base na flag
        action = flag == "1" ? "entrada" : "saida"
      
        # Verificar o status atual do Keylocker
        last_log = Log.where(key_id: keylocker.serial).order(timestamp: :desc).first
      
        if action == "entrada" && last_log&.status == "Ocupado"
          render json: { error: "Ação inválida: o Keylocker já está ocupado" }, status: :unprocessable_entity
          return
        elsif action == "saida" && (!last_log || last_log.status == "Disponível")
          render json: { error: "Ação inválida: o Keylocker já está disponível" }, status: :unprocessable_entity
          return
        end
      
        # Salvar o log
        log = Log.new(
          employee_id: employee.id,
          action: action,
          key_id: keylocker.serial,
          locker_name: keylocker.nameDevice,
          timestamp: Time.now,
          status: action == "entrada" ? "Ocupado" : "Disponível",
          comments: "Nicho associado ao funcionário #{employee.email}"
        )
      
        if log.save
          render json: { message: "Ação registrada com sucesso", log: log }, status: :ok
        else
          render json: { error: "Erro ao salvar o log", details: log.errors.full_messages }, status: :internal_server_error
        end
      end
      
      
      def control_exit
        # Parse do payload recebido
        serial = params[:serial]
        senha = params[:acesso]
        flag = params[:flag]
      
        # Validação dos parâmetros
        if serial.blank? || senha.blank? || !["1", "2"].include?(flag)
          render json: { error: "Parâmetros inválidos" }, status: :unprocessable_entity
          return
        end
      
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
        unless keylocker
          render json: { error: "Keylocker não encontrado" }, status: :not_found
          return
        end
      
        # Encontra o Employee pelo identificador (cardRFID ou pswdSmartlocker)
        employee = Employee.find_by("cardRFID = :senha OR pswdSmartlocker = :senha", senha: senha)
      
        unless employee
          render json: { error: "Funcionário não encontrado" }, status: :not_found
          return
        end
      
        # Definir a ação com base na flag
        action = flag == "1" ? "entrada" : "saida"
      
        # Verificar o status atual do Keylocker
        last_log = Log.where(key_id: keylocker.serial).order(timestamp: :desc).first
      
        if action == "entrada" && last_log&.status == "Ocupado"
          render json: { error: "Ação inválida: o Keylocker já está ocupado" }, status: :unprocessable_entity
          return
        elsif action == "saida" && (!last_log || last_log.status == "Disponível")
          render json: { error: "Ação inválida: o Keylocker já está disponível" }, status: :unprocessable_entity
          return
        end
      
        # Salvar o log
        log = Log.new(
          employee_id: employee.id,
          action: action,
          key_id: keylocker.serial,
          locker_name: keylocker.nameDevice,
          timestamp: Time.now,
          status: action == "entrada" ? "Ocupado" : "Disponível",
          comments: "Nicho associado ao funcionário #{employee.email}"
        )
      
        if log.save
          render json: { message: "Ação registrada com sucesso", log: log }, status: :ok
        else
          render json: { error: "Erro ao salvar o log", details: log.errors.full_messages }, status: :internal_server_error
        end
      end
      
      
      def locker_security
        # Recebe o JSON com os parâmetros
        serial = params[:serial]
        keys = params[:keys]
        
        # Extrai os números da chave "keys"
        key_numbers = keys.gsub("LS", "").strip
        
        # Consulta o keylocker com base no serial
        keylocker = Keylocker.find_by(serial: serial)
        
        if keylocker.nil?
          render json: { status: "ERROR", message: "Locker não encontrado" }, status: :not_found and return
        end
        
        # Variável para verificar se houve alteração
        changes_made = false
        
        # Itera sobre os números extraídos da chave e consulta as posições
        key_numbers.chars.each_with_index do |char, index|
          position = index + 1  # Posições começam em 1 (não 0)
          
          # Consulta o keylockerinfo com base no keylocker e na posição
          keylocker_info = keylocker.keylockerinfos.find_by(posicion: position)
          
          if keylocker_info
            # Verifica se o número é diferente e altera o "empty"
            if char.to_i != keylocker_info.empty
              keylocker_info.update(empty: char.to_i)  # Atualiza para o novo valor (0 ou 1)
              changes_made = true
            end
          end
        end
        
        if changes_made
          # Retorna sucesso se houve alteração
          keylockerinfos = keylocker.keylockerinfos.select(:object, :posicion, :empty).as_json(only: [:posicion, :object, :empty])
          render json: { 
            status: "SUCCESS", 
            message: "Locker atualizado", 
            data: keylocker, 
            keylockerinfos: keylockerinfos 
          }, status: :ok
        else
          # Retorna mensagem de que nenhuma alteração foi feita
          render json: { 
            status: "SUCCESS", 
            message: "Nenhuma alteração foi feita.",
            data: keylocker 
          }, status: :ok
        end
      end

      #FICA
      def esp8288params
        id_nv_usr = params[:ID_NV_USR]
        rfid_nv_usr = params[:RFID_NV_USR]
        snh_nv_usr = params[:SNH_NV_USR]
    
        # Encontre o funcionário com base no campo PIN
        employee = Employee.find_by(PIN: id_nv_usr)
    
        if employee
          # Atualize o campo cardRFID se RFID_NV_USR estiver presente
          employee.update(cardRFID: rfid_nv_usr) if rfid_nv_usr.present?
    
          # Atualize os campos pswdSmartlocker se SNH_NV_USR estiver presente
          if snh_nv_usr.present?
            employee.update(pswdSmartlocker: snh_nv_usr)
            render json: { message: 'Usuário cadastrado com sucesso' }
          else
            render json: { message: 'SNH_NV_USR é obrigatório' }, status: :unprocessable_entity
          end
        else
          render json: { message: 'ID_NV_USR não corresponde a nenhum PIN de funcionário' }, status: :unprocessable_entity
        end
      end


      def process_locker_code
        serial = params[:serial]
        locker_codes = params[:keys] # Renomeado de locker_code para locker_codes
        acesso = params[:acesso] # Renomeado de locker_code para locker_codes

        if locker_codes.present?
          # Remove quebras de linha e espaços em branco
          locker_codes = locker_codes.strip.gsub("\n", "") # Remove quebras de linha e espaços
          locker_codes = locker_codes.gsub('LS ', '') # Remove 'LS ' e pega só o código
      
          # Verifica se locker_codes está vazio após o tratamento
          if locker_codes.empty?
            puts "Erro: Código do locker é vazio após o tratamento."
            return render json: { error: "Código do locker não pode ser vazio." }, status: :bad_request
          end
      
          puts "Códigos dos nichos (sem 'LS '): #{locker_codes.inspect}"
          puts "keys do armario: #{locker_codes.inspect}"

        else
          puts "Erro: 'keys' não está presente nos parâmetros."
          return render json: { error: "Código dos nichos não pode ser vazio." }, status: :bad_request
        end
      
        puts "Serial recebido: #{serial}"
      
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
      end
      
      
      
      
      
      def employees_by_keylocker
        serial = params[:serial]

        # Encontra o Keylocker com o serial fornecido
        keylocker = Keylocker.find_by(serial: serial)

        if keylocker
          # Encontra os funcionários associados ao keylocker
          employees = keylocker.employees

          # Se houver funcionários, retornamos um JSON com os dados solicitados
          if employees.any?
            render json: employees.as_json(only: [:name, :lastname, :phone, :email, :pswdSmartlocker, :cardRFID])
          else
            render json: { error: "Nenhum funcionário encontrado para este keylocker" }, status: :not_found
          end
        else
          # Caso o serial não corresponda a nenhum keylocker
          render json: { error: "Keylocker não encontrado" }, status: :not_found
        end
      end
      
      def process_locker_code
        serial = params[:serial]
        locker_codes = params[:keys] # Estado atual dos nichos
        acesso = params[:acesso] # Pode ser o RFID ou a senha de acesso
      
        # Validações iniciais
        if locker_codes.blank?
          puts "Erro: 'keys' não está presente nos parâmetros ou é vazio."
          return render json: { error: "Código dos nichos não pode ser vazio." }, status: :bad_request
        end
      
        locker_codes = locker_codes.strip.gsub("\n", "") # Remove espaços e quebras de linha
        if locker_codes.empty?
          puts "Erro: Código do locker é vazio após o tratamento."
          return render json: { error: "Código do locker não pode ser vazio." }, status: :bad_request
        end
      
        puts "Serial recebido: #{serial}"
        puts "Locker codes recebidos: #{locker_codes}"
        puts "Acesso recebido: #{acesso}"
      
        # Busca pelo keylocker
        keylocker = Keylocker.find_by(serial: serial)
        if keylocker.nil?
          puts "Erro: Keylocker não encontrado com o serial #{serial}."
          return render json: { error: "Keylocker não encontrado." }, status: :not_found
        end
      
        # Busca pelo funcionário (acesso pode ser por RFID ou senha)
        employee = Employee.find_by(cardRFID: acesso) || Employee.find_by(pswdSmartlocker: acesso)
        if employee.nil?
          puts "Erro: Funcionário não encontrado."
          return render json: { error: "Funcionário não encontrado." }, status: :not_found
        end
      
        # Verifica se o funcionário tem acesso ao keylocker
        unless employee.keylockers.include?(keylocker)
          puts "Erro: Acesso negado ao keylocker."
          return render json: { error: "Acesso negado: o funcionário não tem permissão para este keylocker." }, status: :unauthorized
        end
      
        # Recupera o último estado dos nichos para o keylocker
        last_log = Log.where(key_id: keylocker.serial).order(:timestamp).last
        previous_state = last_log&.status || "0" * locker_codes.length # Default: tudo livre (0s)
      
        puts "Estado anterior: #{previous_state}"
        puts "Estado atual: #{locker_codes}"
      
        # Processa mudanças de estado
        previous_state.chars.each_with_index do |prev_char, index|
          current_char = locker_codes[index]
      
          if prev_char != current_char
            action = current_char == "1" ? "entrada" : "saída"
            status = current_char == "1" ? "Ocupado" : "Livre"
            comments = current_char == "1" ? 
                        "Nicho #{index + 1} ocupado por #{employee.email}" : 
                        "Nicho #{index + 1} liberado por #{employee.email}"
      
            Log.create(
              employee_id: employee.id,
              action: action,
              key_id: keylocker.serial,
              locker_name: keylocker.nameDevice,
              timestamp: Time.now,
              status: status,
              comments: comments
            )
      
            puts "Log criado para o nicho #{index + 1}: Ação #{action}, Status #{status}"
          end
        end
      
        render json: { status: 'Autorizado', message: 'Mudanças registradas com sucesso.' }, status: :ok
      end
      
      

      def check_card_access
        serial = params[:serial]
        snh_card_usr = params[:RFID_NV_USR]
        
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
        
        # Retorna erro se o keylocker não for encontrado ou estiver bloqueado
        if keylocker.nil?
          render json: { status: 'Keylocker não encontrado' }, status: :not_found
          return
        elsif keylocker.status == 'bloqueado'
          render json: { status: 'Locker está bloqueado' }, status: :unauthorized
          return
        end
      
        # Encontra o Employee pelo cartão RFID
        employee = Employee.find_by(cardRFID: snh_card_usr)
        puts "Employee encontrado: #{employee.inspect}"
      
        # Verifica se o Employee é autorizado a acessar o keylocker
        if keylocker && employee && employee.keylockers.include?(keylocker)
          # Salva o employee na sessão
          session[:employee] = {
            id: employee.id,
            name: employee.name,
            lastname: employee.lastname,
            phone: employee.phone,
            email: employee.email
          }
          puts "Sessão salva com sucesso! Employee: #{session[:employee]}"
          
          # Verifica horários de trabalho
          if employee.workdays.exists? && employee.workdays.any?(&:enabled)
            if employee_working_now?(employee)
              render json: { status: 'Acesso autorizado' }, status: :ok
            else
              render json: { status: 'Fora do horário de trabalho' }, status: :unauthorized
            end
          else
            render json: { status: 'Acesso autorizado' }, status: :ok
          end
        else
          render json: { status: 'Acesso não autorizado ou credenciais inválidas' }, status: :unauthorized
        end
      end
      
      
      def check_keypad_access
        serial = params[:serial]
        snh_keypad_usr = params[:SNH_KEYPAD_USR]
        
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
        
        # Retorna erro se o keylocker não for encontrado ou estiver bloqueado
        if keylocker.nil?
          render json: { status: 'Keylocker não encontrado' }, status: :not_found
          return
        elsif keylocker.status == 'bloqueado'
          render json: { status: 'Locker está bloqueado' }, status: :unauthorized
          return
        end
      
        # Encontra o Employee pela senha do Smartlocker
        employee = Employee.find_by(pswdSmartlocker: snh_keypad_usr)
        puts "Employee encontrado: #{employee.inspect}"
      
        # Verifica se o Employee é autorizado a acessar o keylocker
        if keylocker && employee && employee.keylockers.include?(keylocker)
          # Salva o employee na sessão
          session[:employee] = {
            id: employee.id,
            name: employee.name,
            lastname: employee.lastname,
            phone: employee.phone,
            email: employee.email
          }
          puts "Sessão salva com sucesso! Employee: #{session[:employee]}"
          
          # Verifica horários de trabalho
          if employee.workdays.exists? && employee.workdays.any?(&:enabled)
            if employee_working_now?(employee)
              render json: { status: 'Acesso autorizado' }, status: :ok
            else
              render json: { status: 'Fora do horário de trabalho' }, status: :unauthorized
            end
          else
            render json: { status: 'Acesso autorizado' }, status: :ok
          end
        else
          render json: { status: 'Acesso não autorizado ou credenciais inválidas' }, status: :unauthorized
        end
      end
      

      def check_access
        # Determina o serial e a credencial (pode ser RFID ou senha)
        serial = params[:serial]
        credential = params[:RFID_NV_USR] || params[:SNH_KEYPAD_USR]
      
        # Encontra o Keylocker pelo serial
        keylocker = Keylocker.find_by(serial: serial)
      
        # Verifica se o keylocker foi encontrado e se está bloqueado
        if keylocker.nil?
          render json: { status: 'Keylocker não encontrado' }, status: :not_found
          return
        elsif keylocker.status == 'bloqueado'
          render json: { status: 'Locker está bloqueado' }, status: :unauthorized
          return
        end
      
        # Determina o campo para busca baseado na credencial fornecida
        employee = if params[:RFID_NV_USR]
                     Employee.find_by(cardRFID: credential)
                   elsif params[:SNH_KEYPAD_USR]
                     Employee.find_by(pswdSmartlocker: credential)
                   end
      
        # Verifica se keylocker e employee foram encontrados
        if keylocker && employee && employee.keylockers.include?(keylocker)
          puts "Employee encontrado: #{employee.inspect}"
      
          # Verifica se o funcionário tem horário de trabalho configurado e está habilitado
          if employee.workdays.exists? && employee.workdays.any?(&:enabled)
            if employee_working_now?(employee)
              render json: { status: 'Acesso autorizado' }, status: :ok
            else
              render json: { status: 'Fora do horário de trabalho' }, status: :unauthorized
            end
          else
            render json: { status: 'Acesso autorizado' }, status: :ok
          end
        else
          render json: { status: 'Serial ou Credencial inválida' }, status: :unauthorized
        end
      end
      
      def information_locker
        # Obtém o serial da requisição GET
        serial = params[:serial]
      
        # Busca no banco de dados o keylocker pelo serial, incluindo os atributos aninhados
        keylocker = Keylocker.includes(:keylockerinfos).find_by(serial: serial)
      
        if keylocker
          # Retorna as informações do keylocker em JSON, incluindo os atributos aninhados
          render json: {
            status: 'SUCCESS',
            message: 'Locker encontrado',
            data: keylocker.as_json(include: {
              keylockerinfos: {
                only: [:id, :object, :posicion, :empty]
              }
            })
          }, status: :ok
        else
          # Retorna um erro caso o keylocker não seja encontrado
          render json: { status: 'ERROR', message: 'Locker não encontrado' }, status: :not_found
        end
      end
      
      private
      # Método que verifica se o funcionário está dentro do horário de trabalho
      def employee_working_now?(employee)
        # Busca o horário de trabalho do empregado
        workday = Workday.find_by(employee: employee)
      
        # Verifica se há um horário de trabalho e se está habilitado
        if workday && workday.enabled
          current_time = Time.current
          current_day = current_time.strftime("%A").downcase.to_sym  # Obtem o dia da semana em inglês
      
          # Verifica se o dia atual está habilitado
          if workday.send(current_day)
            # Converter horas para minutos desde a meia-noite
            def time_to_minutes(time)
              hours, minutes = time.split(':').map(&:to_i)
              hours * 60 + minutes
            end
      
            workday_start_minutes = time_to_minutes(workday.start.strftime("%H:%M"))
            workday_end_minutes = time_to_minutes(workday.end.strftime("%H:%M"))
            current_time_minutes = time_to_minutes(current_time.strftime("%H:%M"))
      
            # Verifica se o intervalo atravessa a meia-noite
            if workday_start_minutes <= workday_end_minutes
              # Intervalo de trabalho não atravessa a meia-noite
              current_time_minutes >= workday_start_minutes && current_time_minutes <= workday_end_minutes
            else
              # Intervalo de trabalho atravessa a meia-noite
              current_time_minutes >= workday_start_minutes || current_time_minutes <= workday_end_minutes
            end
          else
            false # O dia da semana não está habilitado
          end
        else
          false # Se não houver horário de trabalho ou se estiver desabilitado
        end
      end
      
      
      def set_mailer_settings
        settings = EmailSetting.last
        if settings
          ActionMailer::Base.smtp_settings = {
            address:              settings.address,
            port:                 settings.port,
            user_name:            settings.user_name,
            password:             settings.password,
            authentication:       settings.authentication,
            enable_starttls_auto: settings.enable_starttls_auto,
            tls:                  settings.tls
          }
        end
      end

      def set_locale
        I18n.locale = :pt # Configura o locale para português do Brasil
      end
    end
  end
end
